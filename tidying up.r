pacman::p_load(readr,dplyr)

out<-readRDS("Untidyout.rds")
list2env(out, envir = .GlobalEnv)

names(England)

names(Wales)

Wales$'Index of Multiple Deprivation (IMD) Score'<-NA
Wales$'Index of Multiple Deprivation (IMD) Decile (where 1 is most deprived 10% of LSOAs)'<-NA
Wales<-rename(Wales,"Index of Multiple Deprivation (IMD) Rank (where 1 is most deprived)"='WIMD 2014 Overall Rank(r)')

Wales<-Wales[,names(England)]

Wales<-Wales[,-c(5,9,11)]
England<-England[,-c(5,9,11)]

names(Scotland)
Scotland%>%
  rename("LSOA11NM"='Council Area')

Scotland<-Scotland[,c("DZ_CODE",
  "Area Name",
  "UR8FOLD",
  "URNAME",
  "Population",
  "Area Sq Km",
  "People per Sq Km",
  "Overall_SIMD16_rank"
  )]

names(Scotland)<-names(England)

NIRELAND<-NIRELAND[,-1]
NIRELAND$RUC11CD<-NA
names(NIRELAND)[c(1,2,8,3,5,6,7,4)]<-names(England)
NIRELAND<-NIRELAND[,names(England)]
NIRELAND$Country<-"Northern Ireland"
England$Country<-"England"
Scotland$Country<-"Scotland"
Wales$Country<-"Wales"

UK<-rbind(England,NIRELAND,Scotland,Wales)
str(UK)
UK$`Mid-2017 population`<-as.numeric(UK$`Mid-2017 population`)
UK$`Area Sq Km`<-as.numeric(UK$`Area Sq Km`)
UK$`People per Sq Km`<-as.numeric(UK$`People per Sq Km`)

write_rds(UK,"UK_tidy.rds")
write.csv(UK, "UK_LSOA_POP_IMD_RUC.csv",row.names = FALSE)
