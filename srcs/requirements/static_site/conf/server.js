const express = require('express');
const app = express();
const port = 3000;

// Serve all static files from the current directory
app.use(express.static(__dirname));

// Listen on all network interfaces inside the Docker container
app.listen(port, '0.0.0.0', () => {
  console.log(`Static site listening on port ${port}`);
});
