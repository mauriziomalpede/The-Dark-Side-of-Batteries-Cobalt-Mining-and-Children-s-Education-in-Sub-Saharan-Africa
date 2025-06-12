// Master do-file to run multiple do-files
clear all

// Now we can run the codes that produce all tables and figures 
***************************************************************************************************************************

cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do dhs_mines_data_DRC.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do dhs_mines_data_Zambia.do

// Figures
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Fig_Trends.do 
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Fig_Spatial_Lag.do 
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Fig_Cohort.do 
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Fig_Spatial_Lag_Cohort.do 

// Tables
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_education_baseline.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_education_20k.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_children_baseline.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_children_health.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_migration.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_other_mines.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_SecondaryEdu.do

cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_children_multinomial.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_children6_20y.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_children6_11y_and_12_20y.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_children_anymine.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_children_health_other_mines.do
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication\codes"
do Tab_DRCvsZambia.do

