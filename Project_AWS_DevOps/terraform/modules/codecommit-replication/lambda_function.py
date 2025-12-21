import os
import boto3
import json
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    Lambda function to replicate CodeCommit repository changes from primary to secondary region.
    Triggered by EventBridge on CodeCommit push events.
    """
    try:
        logger.info(f"Event received: {json.dumps(event)}")

        # Get environment variables
        source_region = os.environ['SOURCE_REGION']
        destination_region = os.environ['DESTINATION_REGION']
        source_repo = os.environ['SOURCE_REPO']
        destination_repo = os.environ['DESTINATION_REPO']

        # Extract commit information from event
        detail = event.get('detail', {})
        commit_id = detail.get('commitId')
        reference_name = detail.get('referenceName', 'main')
        repository_name = detail.get('repositoryName')

        logger.info(f"Replicating commit {commit_id} from {source_repo} ({source_region}) to {destination_repo} ({destination_region})")

        # Create CodeCommit clients for both regions
        source_client = boto3.client('codecommit', region_name=source_region)
        dest_client = boto3.client('codecommit', region_name=destination_region)

        # Get the commit from source repository
        try:
            commit_response = source_client.get_commit(
                repositoryName=source_repo,
                commitId=commit_id
            )
            commit_info = commit_response['commit']
            logger.info(f"Retrieved commit: {commit_info['message']}")
        except Exception as e:
            logger.error(f"Failed to get commit from source: {str(e)}")
            raise

        # Get all files from the commit
        try:
            # Get list of differences to know what files changed
            # For initial commit or branch creation, we need to get all files
            differences_response = source_client.get_differences(
                repositoryName=source_repo,
                afterCommitSpecifier=commit_id
            )

            files_to_replicate = []

            # Get content for each changed file
            for diff in differences_response.get('differences', []):
                after_blob = diff.get('afterBlob', {})
                if after_blob and after_blob.get('blobId'):
                    # Get the file content
                    blob_response = source_client.get_blob(
                        repositoryName=source_repo,
                        blobId=after_blob['blobId']
                    )

                    files_to_replicate.append({
                        'filePath': after_blob['path'],
                        'fileContent': blob_response['content']
                    })

            logger.info(f"Retrieved {len(files_to_replicate)} files to replicate")

        except Exception as e:
            logger.error(f"Failed to retrieve files from source: {str(e)}")
            raise

        # Check if destination repository exists and get its HEAD commit
        try:
            dest_branch = dest_client.get_branch(
                repositoryName=destination_repo,
                branchName=reference_name
            )
            parent_commit_id = dest_branch['branch']['commitId']
            logger.info(f"Destination repository exists, parent commit: {parent_commit_id}")
        except dest_client.exceptions.BranchDoesNotExistException:
            logger.info("Destination branch does not exist, will create it")
            parent_commit_id = None
        except Exception as e:
            logger.error(f"Error checking destination repository: {str(e)}")
            raise

        # Create commit in destination repository
        try:
            put_files = [
                {
                    'filePath': file['filePath'],
                    'fileContent': file['fileContent']
                }
                for file in files_to_replicate
            ]

            commit_params = {
                'repositoryName': destination_repo,
                'branchName': reference_name,
                'putFiles': put_files,
                'commitMessage': f"[Replicated] {commit_info['message']}",
                'authorName': commit_info.get('author', {}).get('name', 'Replication Lambda'),
                'email': commit_info.get('author', {}).get('email', 'noreply@aws.com')
            }

            if parent_commit_id:
                commit_params['parentCommitId'] = parent_commit_id

            create_response = dest_client.create_commit(**commit_params)

            logger.info(f"Successfully replicated to destination. New commit ID: {create_response['commitId']}")

            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Replication successful',
                    'sourceCommit': commit_id,
                    'destinationCommit': create_response['commitId']
                })
            }

        except Exception as e:
            logger.error(f"Failed to create commit in destination: {str(e)}")
            raise

    except Exception as e:
        logger.error(f"Replication failed: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Replication failed',
                'error': str(e)
            })
        }
