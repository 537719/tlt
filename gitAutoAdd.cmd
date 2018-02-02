::gitAutoAdd.cmd
::ajoute automatiquement au commit à réaliser tous les nouveaux fichiers du dossier courant
@echo on
goto :debut
:DEBUT 31/01/2018 - 11:57:12,38 création initiale
for /F "delims=*" %%I in ('git status ^|sed -n -e "s/^\t\(.*:\)*/git add /p"') do %%I
git status
goto :eof
On branch statsmodifs
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	modified:   ISstatloop.cmd
	modified:   creestats.cmd
	new file:   getISdir.cmd

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   ESIS.cmd

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	gitAutoAdd.cmd

   ISstatloop.cmd 
   creestats.cmd 
   getISdir.cmd 
   ESIS.cmd 
