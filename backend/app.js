const express = require('express')
const path = require('path')

const app = express();

app.use(express.json())

app.use(express.static(path.join(__dirname, '../frontend')))

// Assurez-vous que createTable est défini ailleurs dans votre code
app.get('/', (req, res)=>{
   res.sendFile(path.join(__dirname, "../frontend", "index.html"));
});

app.listen(3000, ()=>{
    console.log("Serveur en cours d'execution sur le port 3000");
});