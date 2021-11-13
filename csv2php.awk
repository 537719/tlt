# csv2html.awk
# d'après csv2html.awk du 24/11/2020
# créé  08:56 25/10/2021 crée la page php pour le kit sqlmaestro permettant d'accéder aux données sqlite exploitant les données issues du .csv fourni en paramètre
#                        s'utilise à chaque création d'une nouvelle page. Penser à modifier le phpgensettings.php en conséquence
#                        définir le titre comme valeur sur la ligne de commande (paramètre -v="titre de la page"
# MODIF 09:56 08/11/2021 prise en compte du type de champ (texte ou num), dynamisation des libellés. Modifier les valeurs par défaut dans la section BEGIN
# MODIF 22:01 12/11/2021 Ajout du type "numero de série" et lien vers la supervision, pour les UC Linux
# BUG   08:40 13/11/2021 la valeur par défaut de la description des champs n'était pas établie pour cause de = au lieu de == 

function ImplementeFonctionVisuPHP(NomFonction)
# plusieurs des fonctions PHP utilisées sont identiques, au nom de l'objet invoqué près
{
    print "        // function ImplementeFonctionVisuPHP(" NomFonction")"
	print "        protected function " NomFonction "s(Grid $grid)"
	print "        {"
    for (i=1;i<=NF;i++) {
        if (meilleurtype[i]) { # on ne génère pas de colonne si le champ a été détecté comme étant majoritairement vide
            print "            //"
            print "            // View column for " entete[i] " field de type " meilleurtype[i], libtype[meilleurtype[i]]
            for (j in libtype) if (type[i,j]>0) {
                print "            //                  le champ " i,entete[i] " comporte " type[i,j] " lignes de type " j,libtype[j] " soit " qualite_type[i,j] "% des non vides"
            }
            print "            //"
            if (meilleurtype[i] >= 2 && meilleurtype[i] <= 4) { # si type numérique. Le type "NoDossier" est traité comme du texte ce qui n'a aucune importance
            # print "// type numérique"
                print "            $column = new NumberViewColumn('Qte', 'Qte', 'Qté', $this->dataset);"
                print "            $column->setNumberAfterDecimal(0);"
                print "            $column->setThousandsSeparator(',');"
                print "            $column->setDecimalSeparator('');"
                print "            $column->SetFixedWidth(null);"
            } else {
            # print "// type non numérique"
                print "            $column = new TextViewColumn('" entete[i] "', '" entete[i] "', '" accent[i] "', $this->dataset);"
                print "            $column->setMinimalVisibility(ColumnVisibility::PHONE);"
                print "            $column->SetMaxLength(75);"
            }
            print "            $column->SetOrderable(true);"
            print "            $column->SetDescription('Description de " accent[i] "');"
            print "            $grid->" NomFonction "($column);"
            }      
        }      
	print "        }"
	print ""
}

BEGIN {
    IGNORECASE=1
    FS=";"
    OFS=","

    # Définir ici les titres et sous titre de la page s'ils méritent mieux que la simple valeur du basename du fichier d'entrée
    # On peut aussi les passer en paramètre sur la ligne de commande
    # titre=
    label= titre # ne semble pas utilisé dans le résultat final
    if (PageDescription=="")     PageDescription = titre # utilisé dans l'encadré sous le titre
    if (PageIcon=="") PageIcon="alturing.png"
    PageIcon= "../webresources/" PageIcon
    
    # Définir ici la description des champs qui méritent mieux que "valeur de [nom du champ]"
    # description[1]="xxx"
    
    # Définition des libellés de types de champ
    libtype[10]="NumSerie"
    libtype[9]="NoColis"
    libtype[8]="NoDossier"
    libtype[7]="date"
    libtype[6]="heure"
    libtype[5]="dateheure"
    libtype[4]="entier"
    libtype[3]="flottant"
    libtype[2]="pourcent"
    libtype[1]="texte"
    libtype[0]="vide"
    
    # Définition des types SQLite
    SQLiteType[10]="TEXT"
    SQLiteType[9]="TEXT"
    SQLiteType[8]="INTEGER"
    SQLiteType[7]="TEXT"
    SQLiteType[6]="TEXT"
    SQLiteType[5]="TEXT"
    SQLiteType[4]="INTEGER"
    SQLiteType[3]="REAL"
    SQLiteType[2]="REAL"
    SQLiteType[1]="TEXT"
    SQLiteType[0]="TEXT"
    
    generator=""
    for (i in PROCINFO["argv"]) { generator=generator PROCINFO["argv"][i]" "} # récupère toute la ligne de commande contrairement à ARGV[]
    
	print "<?php"
	print "/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
	print " *                                   ATTENTION!"
	print " * Si vous voyez ce  message dans votre navigateur (Internet Explorer, Mozilla Firefox, Google Chrome, etc.)"
	print " * cela signifie que PHP n'est pas correctement installé sur votre serveur web. Reportez-vous au manuel PHP ou consultez votre administrateur système"
	print " * plus d'infos sur : http://php.net/manual/install.php "
	print " *"
	print " * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
    print " Code PHP produit le " strftime("%c",systime()) " par " generator
	print " */"
	print ""
	print "    include_once dirname(__FILE__) . '/components/startup.php';"
	print "    include_once dirname(__FILE__) . '/components/application.php';"
	print "    include_once dirname(__FILE__) . '/' . 'authorization.php';"
	print ""
	print ""
	print "    include_once dirname(__FILE__) . '/' . 'database_engine/sqlite_engine.php';"
	print "    include_once dirname(__FILE__) . '/' . 'components/page/page_includes.php';"
	print ""
	print "    function GetConnectionOptions()"
	print "    {"
	print "        $result = GetGlobalConnectionOptions();"
	print "        GetApplication()->GetUserAuthentication()->applyIdentityToConnectionOptions($result);"
	print "        return $result;"
	print "    }"
	print ""
	print "    "
	print "    "
	print "    "
	print "    // OnBeforePageExecute event handler"
	print "    "
	print "    "
  # A partir d'ici le contenu est produit en fonction des champs du fichier fourni

}

NR==1 { # traitement de la ligne d'en-tête
    split(FILENAME,splitname,".") # sépare nom et extension du fichier d'entrée
    if (titre !~ /./)  titre="Visualisation de " splitname[1]
    if (label !~ /./)  label=splitname[1]

    if ($1 !~ /[^0-9][A-z]+$/) if ($1 !~ /[0-9]{4}/) { # 1° champ ne commence pas par un chiffre puis ne contient que des lettres ET 1° champ n'est pas une année
        print "ERREUR : Manque l'intitulé des champs " NR "@" $1 "@"
        exit 1
    }

    nbchamps=NF # détermine le nombre de champs du fichier
    for (i=1;i<=NF;i++) {    # sauvegarde les noms des champs avec accents et espaces, pour affichage
        accent[i]=$i
        # Constitution des descriptions par défaut. Si on a de meilleurs libellés à afficher, les définir dans la section BEGIN
        if (description[i]=="") description[i]="Valeur de " accent[i]
    }
    gsub(/ /,"_") # remplace tous les espaces par des _
    gsub(/.\251/,"e") # 251 = conversion en octal de 169 en décimal, code ascii du é - le . avant le \251 est là  parce que ce caractère est codé sur 2 digits
    for (i=1;i<=NF;i++) {    # détermine les noms des champs, sans accents ni espaces, pour traitement des données
        entete[i]=$i
        if ($i !~ /./) { # cas particulier des champs dont l'en-tête est vide
            entete[i] = "champ_" i
        }
    }
}


NR > 1 { #MAIN - Détermine le type de chaque champ
    # print $0
    for (i=1;i<=NF;i++) {
        # suppression des espaces en début et fin de donnée
        gsub(/^ */,"",$i)
        gsub(/ *$/,"",$i)
        
        # détermination du type de donnée
        if ($i) switch($i) {
            case /^CZC[0-9]{4}[0-z]{3}$/ :
            # numéro de série d'UC HP, regexp à modifier en cas de changement de fournisseur
            {   #NoSerie
                type[i,10]++
                break
            }
            case /[A-Z]{2}[0-9]{9}[A-Z]{2}/ :
            # pas de calage sur les début et fin de champ car il peut y avoir plusieurs NoColis à l'intérieur
            {   #NoColis
                type[i,9]++
                break
            }
            case /^[0-9]{10}$/ :
            {   #NoDossier
                type[i,8]++
                break
            }
            # case /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ :
            # {   #date
                # type[i,7]++
                # break
            # }
            case /^[0-9]*[-|\/][0-9]*[-|\/][0-9]*$/ :
            {   #date
                type[i,7]++
                break
            }
            case /^[0-9]{2}:[0-9]{2}:[0-9]{2}$/ :
            {   #heure
                type[i,6]++
                break
            }
            case /^[0-9]*[-|\/][0-9]*[-|\/][0-9] +[0-9]{2}:[0-9]{2}:[0-9]{2}$/ :
            {   #dateheure
                type[i,5]++
                break
            }
            case /^[0-9]{4}-[0-9]{2}-[0-9]{2} +[0-9]{2}:[0-9]{2}:[0-9]{2}$/ :
            {   #dateheure
                type[i,5]++
                break
            }
            case /^[0-9]+$/ :
            {   #int
                type[i,4]++
                break
            }
            case /^[0-9| ]+[,|\.][0-9| ]+$/ :
            {   #float
                type[i,3]++
                break
            }
            case /^[0-9| |,|\.]+%$/ :
            {   # %
                type[i,2]++
                break
            }
            default :
            {   # txt
                type[i,1]++
            }
        } else {
            # vide
            type[i,0]++
        }
        # print "ligne " NR,"champ " i,$i
        # for (j=0;j<=9;j++){
            # if (type[i,j] >0) {
                # print type[i,j],libtype[j]
            # }
        # }
    } 
    # print ""
}
END {
    for (i=1;i<=NF;i++) { # Calcul du type de chaque champ
    # for (i=1;i<=3;i++) {
        # print "champ " i , entete[i]  
        meilleurtype[i]=0
        for (j in libtype) {
            # print "champ "  i , entete[i]  ", type " j ,libtype[j] " = " type[i,j]+0 " meilleur type = " meilleurtype[i] " avec " type[i,meilleurtype[i]] " valeurs"
            qualite_type[i,j]=100*type[i,j] / ((NR-1)-type[i,0])
            if (type[i,j] > type[i,meilleurtype[i]])      meilleurtype[i]=j
            if (type[i,j]>0)                print "// le champ " i,entete[i] " comporte " type[i,j] " lignes de type " j,libtype[j] " soit " qualite_type[i,j] "% des non vides"
            # Le test ci-dessous ne marche pas pour l'instant. comme il ne concerne qu'un cas ultra spécifique, on verra plus tard
            # if (meilleurtype[i] == 8) {
                # print "// "j",typedossier " meilleurtype[i],libtype[meilleurtype[i]] " qualité " qualite_type[i,j]
                # if (qualite_type[i,j] < 95) {
                    # meilleurtype[i] = 4 # on ne considère comme étant de type "NoDossier" que les champs qui en contiennent plus de 95%
                # }
            # }
        }
        if (meilleurtype[i] >= 5 && meilleurtype[i] <= 7) meilleurtype[i]=1 # les horodatages sont traités comme des textes
        # print "le meilleur type pour le champ " i " " entete[i] " est " meilleurtype[i], libtype[meilleurtype[i]]
    }


# ecriture des parties dépendant des champs détectés
	print ""
	print "    class " splitname[1] "Page extends Page"
	print "    {"
	print "        protected function DoBeforeCreate()"
	print "        {"
	print "            $this->SetTitle('" titre "');"
	print "            $this->SetMenuLabel('" label "');"
	print "    "
	print "            $this->dataset = new TableDataset("
	print "                Sqlite3ConnectionFactory::getInstance(),"
	print "                GetConnectionOptions(),"
	print "                '\"" splitname[1] "\"');"
	print "            $this->dataset->addFields("
	print "                array("
    for (i=1;i<NF;i++) if (meilleurtype[i]) {
        print "                    new StringField('" entete[i]"', false, true),"
    }
        print "                    new StringField('" entete[NF]"', false, true)"
	print "                )"
	print "            );"
	print "        }"
    print ""
	print "        protected function DoPrepare() {"
	print "    "
	print "        }"
	print "    "
	print "        protected function CreatePageNavigator()"
	print "        {"
	print "            $result = new CompositePageNavigator($this);"
	print "            "
	print "            $partitionNavigator = new PageNavigator('pnav', $this, $this->dataset);"
	print "            $partitionNavigator->SetRowsPerPage(20);"
	print "            $result->AddPageNavigator($partitionNavigator);"
	print "            "
	print "            return $result;"
	print "        }"
	print "    "
	print "        protected function CreateRssGenerator()"
	print "        {"
	print "            return null;"
	print "        }"
	print "    "
	print "        protected function setupCharts()"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function getFiltersColumns()"
	print "        {"
	print "            return array("
    for (i=1;i<NF;i++) if (meilleurtype[i]) {
        print "                new FilterColumn($this->dataset, '" entete[i] "', '" entete[i] "', '" accent[i] "'),"
	}
        print "                new FilterColumn($this->dataset, '" entete[NF] "', '" entete[NF] "', '" accent[NF] "')"
	print "            );"
	print "        }"
	print "    "
	# print ""
	print "        protected function setupQuickFilter(QuickFilter $quickFilter, FixedKeysArray $columns)"
	print "        {"
	print "            $quickFilter"
    for (i=1;i<NF;i++) if (meilleurtype[i]) {
        print "                ->addColumn($columns['" entete[i] "'])"
    }
    print "                ->addColumn($columns['" entete[NF] "']);"
	print "        }"
	print "    "
	# print ""
    
	print "        protected function setupColumnFilter(ColumnFilter $columnFilter)"
	print "        {"
	print "            $columnFilter"
    for (i=1;i<NF;i++) if (meilleurtype[i]) {
        print "                ->setOptionsFor('" entete[i] "')"
    }
    print "                ->setOptionsFor('" entete[NF] "');"
	print "        }"
	print "    "
	print ""
	print "         protected function setupFilterBuilder(FilterBuilder $filterBuilder, FixedKeysArray $columns)"
	print "        {"
    for (i=1;i<=NF;i++) if (meilleurtype[i]) {
        print "            $main_editor = new TextEdit('" entete[i] "');"
        print "            "
        print "            $filterBuilder->addColumn("
        print "                $columns['" entete[i] "'],"
        print "                array("
        print "                    FilterConditionOperator::EQUALS => $main_editor,"
        print "                    FilterConditionOperator::DOES_NOT_EQUAL => $main_editor,"
        print "                    FilterConditionOperator::IS_GREATER_THAN => $main_editor,"
        print "                    FilterConditionOperator::IS_GREATER_THAN_OR_EQUAL_TO => $main_editor,"
        print "                    FilterConditionOperator::IS_LESS_THAN => $main_editor,"
        print "                    FilterConditionOperator::IS_LESS_THAN_OR_EQUAL_TO => $main_editor,"
        print "                    FilterConditionOperator::IS_BETWEEN => $main_editor,"
        print "                    FilterConditionOperator::IS_NOT_BETWEEN => $main_editor,"
        print "                    FilterConditionOperator::CONTAINS => $main_editor,"
        print "                    FilterConditionOperator::DOES_NOT_CONTAIN => $main_editor,"
        print "                    FilterConditionOperator::BEGINS_WITH => $main_editor,"
        print "                    FilterConditionOperator::ENDS_WITH => $main_editor,"
        print "                    FilterConditionOperator::IS_LIKE => $main_editor,"
        print "                    FilterConditionOperator::IS_NOT_LIKE => $main_editor,"
        print "                    FilterConditionOperator::IS_BLANK => null,"
        print "                    FilterConditionOperator::IS_NOT_BLANK => null"
	print "                )"
	print "            );"
    }
	print "        }    "
	print ""   
	print "        protected function AddOperationsColumns(Grid $grid)"
	print "        {"
	print "            $actions = $grid->getActions();"
	print "            $actions->setCaption($this->GetLocalizerCaptions()->GetMessageString('Actions'));"
	print "            $actions->setPosition(ActionList::POSITION_LEFT);"
	print "            "
	print "            if ($this->GetSecurityInfo()->HasViewGrant())"
	print "            {"
	print "                $operation = new LinkOperation($this->GetLocalizerCaptions()->GetMessageString('View'), OPERATION_VIEW, $this->dataset, $grid);"
	print "                $operation->setUseImage(true);"
	print "                $actions->addOperation($operation);"
	print "            }"
	print "        }"
	print "    "

    print "        protected function AddFieldColumns(Grid $grid, $withDetails = true)"
	print "        {"
    for (i=1;i<=NF;i++) {
        if (meilleurtype[i]) { # on ne génère pas de colonne si le champ a été détecté comme étant majoritairement vide
            print "            //"
            print "            // View column for " entete[i] " field"
            print "            //"
            print "            $column = new StringTransformViewColumn('" entete[i] "', '" entete[i] "', '" accent[i] "', $this->dataset);"
            print "            $column->SetOrderable(true);"
          # print "type " meilleurtype[i] OFS libtype[meilleurtype[i]]
           if (meilleurtype[i] <= 7) {
                print "            $column->SetDescription('" description[i] "');"
            }
            if (meilleurtype[i] == 8) {
                print "            $column->setTarget('_blank');"
                print "            $column->setStringTransformFunction('');"
                print "            $column->setHrefTemplate('https://glpi.alturing.eu/front/ticket.form.php?id=%" entete[i] "%');"
                print "            $column->SetDescription('Num&eacute;ro du dossier GLPI sur lequel le produit a &eacute;t&eacute; trait&eacute;');"
            }
            if (meilleurtype[i] == 9) {
                print "            $column->setTarget('_blank');"
                print "            $column->setStringTransformFunction('');"
                print "            $column->setHrefTemplate('http://suivi.chronopost.fr/servletAuguste?Hrequete=recherche&amp;TAlisteNumeroLT=%" entete[i] "%&amp;RBresultats=ecran&amp;TFNumeroLTPartiel=&amp;StypeCalcul=commun&amp;StypeRecherche=tous');"
                print "            $column->SetDescription('Num&eacute;ro(s) de colis (si envoi par Chronopost). Plusieurs articles du m&ecirc;me dossier peuvent &ecirc;tre un m&ecirc;me colis');"
            }
            if (meilleurtype[i] == 10) {
                print "            $column->setTarget('_blank');"
                print "            $column->setStringTransformFunction('');"
                print "            $column->setHrefTemplate('http://lyarg1.tlt/installer/pmc/PROD/ALL/uploads/pby%" tolower(entete[i]) "%.chronopost.net.supervision.html');"
                print "            $column->SetDescription('Acc&egrave;s &agrave; la supervision');"
            }
            
            print "            $column->SetMaxLength(75);"
            print "            $column->setMinimalVisibility(ColumnVisibility::PHONE);"
            print "            $column->SetFixedWidth(null);"
            print "            $grid->AddViewColumn($column);"
        }      
    }      
	print "        }"
    ImplementeFonctionVisuPHP("AddSingleRecordViewColumn") 
	print "        protected function AddEditColumns(Grid $grid)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function AddMultiEditColumns(Grid $grid)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function AddInsertColumns(Grid $grid)"
	print "        {"
	print "    "
	print "            $grid->SetShowAddButton(false && $this->GetSecurityInfo()->HasAddGrant());"
	print "        }"
	print "    "
	print "        private function AddMultiUploadColumn(Grid $grid)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print ""  
    ImplementeFonctionVisuPHP("AddPrintColumn") 
    ImplementeFonctionVisuPHP("AddExportColumn") 
    ImplementeFonctionVisuPHP("AddCompareColumn") 
	print "        private function AddCompareHeaderColumns(Grid $grid)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        public function GetPageDirection()"
	print "        {"
	print "            return null;"
	print "        }"
	print "    "
	print "        public function isFilterConditionRequired()"
	print "        {"
	print "            return false;"
	print "        }"
	print "    "
	print "        protected function ApplyCommonColumnEditProperties(CustomEditColumn $column)"
	print "        {"
	print "            $column->SetDisplaySetToNullCheckBox(false);"
	print "            $column->SetDisplaySetToDefaultCheckBox(false);"
	print "    		$column->SetVariableContainer($this->GetColumnVariableContainer());"
	print "        }"
	print "    "
	print "        function GetCustomClientScript()"
	print "        {"
	print "            return ;"
	print "        }"
	print "        "
	print "        function GetOnPageLoadedClientScript()"
	print "        {"
	print "            return ;"
	print "        }"
	print "    "
	print ""    
    
	print "        protected function CreateGrid()"
	print "        {"
	print "            $result = new Grid($this, $this->dataset);"
	print "            if ($this->GetSecurityInfo()->HasDeleteGrant())"
	print "               $result->SetAllowDeleteSelected(false);"
	print "            else"
	print "               $result->SetAllowDeleteSelected(false);   "
	print "            "
	print "            ApplyCommonPageSettings($this, $result);"
	print "            "
	print "            $result->SetUseImagesForActions(true);"
	print "            $defaultSortedColumns = array();"
	print "            $defaultSortedColumns[] = new SortColumn('Code', 'ASC');"
	print "            $result->setDefaultOrdering($defaultSortedColumns);"
	print "            $result->SetUseFixedHeader(false);"
	print "            $result->SetShowLineNumbers(false);"
	print "            $result->SetShowKeyColumnsImagesInHeader(false);"
	print "            $result->setAllowSortingByDialog(false);"
	print "            $result->SetViewMode(ViewMode::TABLE);"
	print "            $result->setEnableRuntimeCustomization(false);"
	print "            $result->setAllowAddMultipleRecords(false);"
	print "            $result->setMultiEditAllowed($this->GetSecurityInfo()->HasEditGrant() && false);"
	print "            $result->setTableBordered(false);"
	print "            $result->setTableCondensed(false);"
	print "            "
	print "            $result->SetHighlightRowAtHover(false);"
	print "            $result->SetWidth('');"
	print "            $this->AddOperationsColumns($result);"
	print "            $this->AddFieldColumns($result);"
	print "            $this->AddSingleRecordViewColumns($result);"
	print "            $this->AddEditColumns($result);"
	print "            $this->AddMultiEditColumns($result);"
	print "            $this->AddInsertColumns($result);"
	print "            $this->AddPrintColumns($result);"
	print "            $this->AddExportColumns($result);"
	print "            $this->AddMultiUploadColumn($result);"
	print "    "
	print "    "
	print "            $this->SetShowPageList(true);"
	print "            $this->SetShowTopPageNavigator(true);"
	print "            $this->SetShowBottomPageNavigator(true);"
	print "            $this->setPrintListAvailable(true);"
	print "            $this->setPrintListRecordAvailable(true);"
	print "            $this->setPrintOneRecordAvailable(true);"
	print "            $this->setAllowPrintSelectedRecords(true);"
	print "            $this->setOpenPrintFormInNewTab(true);"
	print "            $this->setExportListAvailable(array('pdf', 'excel', 'word', 'xml', 'csv'));"
	print "            $this->setExportSelectedRecordsAvailable(array('pdf', 'excel', 'word', 'xml', 'csv'));"
	print "            $this->setExportListRecordAvailable(array());"
	print "            $this->setExportOneRecordAvailable(array('pdf', 'excel', 'word', 'xml', 'csv'));"
	print "            $this->setOpenExportedPdfInNewTab(false);"
	print "            $this->setDescription('<img src=\"" PageIcon "\""
	print "                 align=top border=none width=32p>"
	print "            " PageDescription " au "
	print "            <object type=\"text/plain\" "
	print "                    data=\"" splitname[1] ".txt\" " #" double quote présente juste pour que la coloration syntaxique retombe sur ses pieds
	print "                    style=\"overflow: visible ;\" "
	print "                    border=\"0\" "
	print "                    height=\"25\" "
	print "                    width=\"130\""
	print "            >"
	print "            </object>');"
	print "            $this->setDetailedDescription('Tri, recherche et filtrage possible en utilisant les options de la page"
	print "            Utiliser la barre de recherche pour cibler un détail en particulier"
	print "            {Consulter] pour une vue détaillée');"
	print "    "
	print "            return $result;"
	print "        }"
	print "     "
	print "        protected function setClientSideEvents(Grid $grid) {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doRegisterHandlers() {"
	print "            "
	print "            "
	print "        }"
	print "       "
	print "        protected function doCustomRenderColumn($fieldName, $fieldData, $rowData, &$customText, &$handled)"
	print "        { "
	print "    "
	print "        }"
	print "    "
	print "        protected function doCustomRenderPrintColumn($fieldName, $fieldData, $rowData, &$customText, &$handled)"
	print "        { "
	print "    "
	print "        }"
	print "    "
	print "        protected function doCustomRenderExportColumn($exportType, $fieldName, $fieldData, $rowData, &$customText, &$handled)"
	print "        { "
	print "    "
	print "        }"
	print "    "
	print "        protected function doCustomDrawRow($rowData, &$cellFontColor, &$cellFontSize, &$cellBgColor, &$cellItalicAttr, &$cellBoldAttr)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doExtendedCustomDrawRow($rowData, &$rowCellStyles, &$rowStyles, &$rowClasses, &$cellClasses)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doCustomRenderTotal($totalValue, $aggregate, $columnName, &$customText, &$handled)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doCustomDefaultValues(&$values, &$handled) "
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doCustomCompareColumn($columnName, $valueA, $valueB, &$result)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doBeforeInsertRecord($page, &$rowData, $tableName, &$cancel, &$message, &$messageDisplayTime)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doBeforeUpdateRecord($page, $oldRowData, &$rowData, $tableName, &$cancel, &$message, &$messageDisplayTime)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doBeforeDeleteRecord($page, &$rowData, $tableName, &$cancel, &$message, &$messageDisplayTime)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doAfterInsertRecord($page, $rowData, $tableName, &$success, &$message, &$messageDisplayTime)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doAfterUpdateRecord($page, $oldRowData, $rowData, $tableName, &$success, &$message, &$messageDisplayTime)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doAfterDeleteRecord($page, $rowData, $tableName, &$success, &$message, &$messageDisplayTime)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doCustomHTMLHeader($page, &$customHtmlHeaderText)"
	print "        { "
	print "    "
	print "        }"
	print "    "
	print "        protected function doGetCustomTemplate($type, $part, $mode, &$result, &$params)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doGetCustomExportOptions(Page $page, $exportType, $rowData, &$options)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doFileUpload($fieldName, $rowData, &$result, &$accept, $originalFileName, $originalFileExtension, $fileSize, $tempFileName)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doPrepareChart(Chart $chart)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doPrepareColumnFilter(ColumnFilter $columnFilter)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doPrepareFilterBuilder(FilterBuilder $filterBuilder, FixedKeysArray $columns)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doGetSelectionFilters(FixedKeysArray $columns, &$result)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doGetCustomFormLayout($mode, FixedKeysArray $columns, FormLayout $layout)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doGetCustomColumnGroup(FixedKeysArray $columns, ViewColumnGroup $columnGroup)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doPageLoaded()"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doCalculateFields($rowData, $fieldName, &$value)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doGetCustomRecordPermissions(Page $page, &$usingCondition, $rowData, &$allowEdit, &$allowDelete, &$mergeWithDefault, &$handled)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "        protected function doAddEnvironmentVariables(Page $page, &$variables)"
	print "        {"
	print "    "
	print "        }"
	print "    "
	print "    }"
	print ""
	print "    SetUpUserAuthorization();"
	print ""
	print "    try"
	print "    {"
	print "        $Page = new " splitname[1] "Page(\"" splitname[1] "\", \"" splitname[1] ".php\", GetCurrentUserPermissionsForPage(\"" splitname[1] "\"), 'UTF-8');"
	print "        $Page->SetRecordPermission(GetCurrentUserRecordPermissionsForDataSource(\"" splitname[1] "\"));"
	print "        GetApplication()->SetMainPage($Page);"
	print "        GetApplication()->Run();"
	print "    }"
	print "    catch(Exception $e)"
	print "    {"
	print "        ShowErrorPage($e);"
	print "    }"
	print "	"
    print "/* La table support de ce script doit avoir la structure suivante :"
    print "CREATE TABLE " splitname[1] "("
    for (i=1;i<=NF;i++)   {
        print "     " entete[i] "   " SQLiteType[meilleurtype[i]] " NOT NULL,"
    }
    print "     -- clauses CHECK éventuelles"
    print ");"
    print "*/"

}