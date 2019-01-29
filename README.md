# UK_IMD_POPDEN_RUC
Coercing deprivation, population density and urban rural classification for all UK small areas in to a single tidy dataframe.

"IMD_POP_RUC.r" contains the code to download the deprivation, population and urban rural classification for England, Scotland,
Northern Ireland and Wales.

The output of this is a data frame for each country stored in "untidyout.rds"

"tidying up.r" takes "untidyout.rds", tidies it and combines it into a single dataframe for each country.
