<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleBite - Contact</title>
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
        <section class="content">
            <h1>Contact Us</h1>

            <div class="contact-info">
                <h2>Get in Touch</h2>
                <p><strong>Email:</strong> info@applebite.com</p>
                <p><strong>Phone:</strong> +1 (555) 123-4567</p>
                <p><strong>Address:</strong> 123 Cloud Street, Tech City, TC 12345</p>
            </div>

            <div class="contact-form">
                <h2>Send us a message</h2>
                <form action="#" method="post">
                    <div class="form-group">
                        <label for="name">Name:</label>
                        <input type="text" id="name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    <div class="form-group">
                        <label for="message">Message:</label>
                        <textarea id="message" name="message" rows="5" required></textarea>
                    </div>
                    <button type="submit">Send Message</button>
                </form>
            </div>
        </section>
    </main>

    <footer>
        <p>&copy; 2024 AppleBite Co. All rights reserved.</p>
    </footer>
</body>

</html>