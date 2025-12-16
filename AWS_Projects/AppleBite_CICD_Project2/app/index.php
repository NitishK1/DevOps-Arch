<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleBite - Home</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
    <header>
        <nav>
            <div class="logo">AppleBite</div>
            <ul>
                <li><a href="index.php">Home</a></li>
                <li><a href="about.php">About</a></li>
                <li><a href="contact.php">Contact</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <section class="hero">
            <h1>Welcome to AppleBite</h1>
            <p>Your premier solution for cloud-based products</p>
            <p class="version">Version: <?php echo getenv('APP_VERSION') ?: '1.0'; ?></p>
        </section>

        <section class="features">
            <h2>Our Services</h2>
            <div class="feature-grid">
                <div class="feature-card">
                    <h3>Cloud Solutions</h3>
                    <p>Scalable and reliable cloud infrastructure</p>
                </div>
                <div class="feature-card">
                    <h3>DevOps Integration</h3>
                    <p>Continuous Integration and Deployment</p>
                </div>
                <div class="feature-card">
                    <h3>Microservices</h3>
                    <p>Modular component architecture</p>
                </div>
            </div>
        </section>

        <section class="info">
            <h2>System Information</h2>
            <p><strong>Server:</strong> <?php echo $_SERVER['SERVER_NAME']; ?></p>
            <p><strong>PHP Version:</strong> <?php echo phpversion(); ?></p>
            <p><strong>Deployment Time:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
        </section>
    </main>

    <footer>
        <p>&copy; 2024 AppleBite Co. All rights reserved.</p>
    </footer>
</body>

</html>