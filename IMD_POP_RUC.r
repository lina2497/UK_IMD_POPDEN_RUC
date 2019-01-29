pacman::p_load(readxl,readr,dplyr)

#Functions
read_excel_allsheets <- function(filename, tibble = FALSE) {
  # I prefer straight data.frames
  # but if you like tidyverse tibbles (the default with read_excel)
  # then just pass tibble = TRUE
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

###URLS####
Eng_IMD_URL<-"https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/467774/File_7_ID_2015_All_ranks__deciles_and_scores_for_the_Indices_of_Deprivation__and_population_denominators.csv"
EW_RUC_URL<-"https://opendata.arcgis.com/datasets/276d973d30134c339eaecfc3c49770b3_0.csv"
EW_Pop_URL<-"https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareapopulationdensity/mid2017/sape20dt11mid2017lsoapopulationdensity.zip"
W_IMD_URL<-"http://gov.wales/docs/statistics/2015/150812-wimd-2014-overall-domain-ranks-each-lsoa-revised-en.xlsx"
SIMD_URL<-"https://www2.gov.scot/Resource/0053/00534450.xlsx"
S_POP_URL<-"https://www.nrscotland.gov.uk/files//statistics/population-estimates/sape-17/sape-17-persons.xlsx"
S_AREA_URL<-"https://statistics.gov.scot/downloads/cube-table?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fland-area-2011-data-zone-based"
S_RUC_URL<-"https://www2.gov.scot/Resource/0054/00544928.csv"
S_RUC_META_URL<-"https://www2.gov.scot/Resource/0054/00544933.csv"
NI_POP_URL<-"https://www.nisra.gov.uk/sites/nisra.gov.uk/files/publications/SAPE17_SA_Totals.xlsx"
NI_IMD_URL<-"https://www.nisra.gov.uk/sites/nisra.gov.uk/files/publications/NIMDM17_SA%20-%20for%20publication.xls"
#NI_RUC_URL<-"https://www.nisra.gov.uk/sites/nisra.gov.uk/files/publications/Settlement15-lookup_0.xls"
#NI RUC data is already present in the NI IMD data
#NI_AREA_URL<-"https://www.nisra.gov.uk/support/geography/northern-ireland-small-areas"
#NI areas extracted from ESRI shapefile using qGIS

###File Downloads####
download.file(Eng_IMD_URL, destfile = "EIMD.csv",mode = "wb")
download.file(EW_RUC_URL, destfile = "EW_RUC.csv",mode = "wb")
download.file(EW_Pop_URL, destfile = "EW_Pop.zip",mode = "wb")
download.file(W_IMD_URL, destfile = "W_IMD.xlsx",mode = "wb")
download.file(SIMD_URL, destfile = "SIMD.xlsx",mode = "wb")
download.file(S_POP_URL, destfile = "S_POP.xlsx",mode = "wb")
download.file(S_RUC_URL, destfile = "S_RUC.csv",mode = "wb")
download.file(S_RUC_META_URL, destfile = "S_RUC_META.csv",mode = "wb")
#S_AREA_URL download manually
download.file(NI_POP_URL, destfile = "NI_POP.xlsx",mode = "wb")
download.file(NI_IMD_URL, destfile = "NI_IMD.xls",mode = "wb")


###Read Files####
EIMD<-read_csv("EIMD.csv")
EW_RUC<-read_csv("EW_RUC.csv")
EW_Pop<-read_excel_allsheets(unzip("EW_Pop.zip"))
W_IMD<-read_excel_allsheets("W_IMD.xlsx")
SIMD<-read_excel_allsheets("SIMD.xlsx")
S_POP<-read_excel_allsheets("S_POP.xlsx")
S_AREA<-read_csv("S_AREA.csv")
S_RUC<-read_csv("S_RUC.csv")
S_RUC_META<-read_csv("S_RUC_META.csv")
NI_POP<-read_excel_allsheets("NI_POP.xlsx")
NI_IMD<-read_excel_allsheets("NI_IMD.xls")
NI_AREA<-read_csv("NI_AREA.csv")

###########England and Wales##########

#tidy EW_pop
EW_Pop<-EW_Pop$`Mid-2017 Population Density`
colnames(EW_Pop)<-EW_Pop[4,]
EW_Pop<-EW_Pop[-c(1:4),]

#join lookups
EW_RUC_POP<-left_join(EW_RUC,select(EW_Pop,-Name), by=c("LSOA11CD"="Code"))
EW_RUC_POP_IMD<-left_join(EW_RUC_POP,select(EIMD,c(1,5:7)),by=c("LSOA11CD"="LSOA code (2011)"))

##England####
#join lookups
E_RUC_POP_IMD<-EW_RUC_POP_IMD[!is.na(EW_RUC_POP_IMD[,11]),]

#output
write.csv(E_RUC_POP_IMD,file = "E_RUC_POP_IMD.csv",row.names = FALSE)

##Wales####
#join lookups
W_IMD_df<-W_IMD$`Deciles etc`
WE_RUC_POP_IMD<-left_join(EW_RUC_POP,W_IMD_df, by=c("LSOA11CD"="LSOA Code"))
W_RUC_POP_IMD<-WE_RUC_POP_IMD[!is.na(WE_RUC_POP_IMD$`LSOA Name (Eng)`),]

#output
write.csv(W_RUC_POP_IMD,file = "W_RUC_POP_IMD.csv",row.names = FALSE)

##Scotland####

SIMD_df <-SIMD$`SIMD16 ranks`

#Wrangle S_POP_df
S_POP_df<-S_POP$`Table 1a Persons (2017)`
names(S_POP_df)[1:4]<-c(S_POP_df[2,1:3],"Population")
S_POP_df<-S_POP_df[-c(1:5),-c(5:96)]
S_POP_df<-S_POP_df[!is.na(S_POP_df$'Population'),]

#Calculate population density
S_AREA$'Area Sq Km'<-S_AREA$Value*0.01
S_POP_DEN<-left_join(S_POP_df,select(S_AREA,-c(2:5)), by = c("Area"="FeatureCode"))
S_POP_DEN$"People per Sq Km"<- as.numeric(S_POP_DEN$Population)/S_POP_DEN$`Area Sq Km`

#join lookups
S_RUC_df<-left_join(S_RUC[,-c(2:4)],S_RUC_META[,-3], by=c("UR8FOLD"="URCLASS"))
S_RUC_POP<-left_join(S_RUC_df,S_POP_DEN, by=c("DZ_CODE"="Area"))
S_RUC_POP_IMD<-left_join(S_RUC_POP,SIMD_df[,-c(2:5,7:13)],by=c("DZ_CODE"="Data_Zone"))

#output
write.csv(S_RUC_POP_IMD, file= "S_RUC_POP_IMD.csv",row.names = FALSE)

##Northern Ireland ####
NI_AREA$'Area Sq Km'<-NI_AREA$Hectares*0.01
NI_IMD_df<-NI_IMD$MDM[,c(1,3,4,2,5)]
NI_POP<-NI_POP$Flat
NI_POP<-filter(NI_POP,Year==2017)
NI_POP_Den<-left_join(NI_POP[,c(2,4)],NI_AREA[,c(1,6)], by=c("Area_Code"="SA2011"))
names(NI_POP_Den)[2]<-"Population"
NI_POP_Den$"People per Sq Km"<-NI_POP_Den$Population/NI_POP_Den$`Area Sq Km`
NI_RUC_POP_IMD<-left_join(NI_IMD_df,NI_POP_Den,by=c("SA2011"="Area_Code"))

#output
write.csv(NI_RUC_POP_IMD,"NI_RUC_POP_IMD.csv",row.names = FALSE)


Out<-list("England"= E_RUC_POP_IMD,"Wales"=W_RUC_POP_IMD,"Scotland"=S_RUC_POP_IMD,"NIRELAND"= NI_RUC_POP_IMD)


write_rds(Out,"untidyout.rds")



