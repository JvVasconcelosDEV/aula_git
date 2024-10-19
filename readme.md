git init // inicia repositorio local
git add <nome do seu arquivo> // adiciona na fila os nossos arquivos a serem enviados para o repositorio da nuvem
git commit -m <"sua mensagem"> // comenta o que foi modificado
git config --global user.email "seuemail@exemplo.com" // 
git config --global user.name "Seu nome"
git branch -M "main" // dá o nome da nossa branch local
git remote add origin <seu link> // faz a conexão do repositorio local e o da nuvem
git push -u origin main // envia as modificações para o repositorio da nuvem