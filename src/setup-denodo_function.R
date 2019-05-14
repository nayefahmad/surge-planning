

#***************************************************
# Function to set up denodo connections 

#***************************************************

# function definition: 
setup_denodo <- function(){
      cnx <<- dbConnect(odbc::odbc(),
                       dsn = "cnx_denodo_spappcsta001")
      
      vw_census <<- dplyr::tbl(cnx, 
                              dbplyr::in_schema("publish", 
                                                "census"))
      vw_eddata <<- dplyr::tbl(cnx, 
                              dbplyr::in_schema("publish", 
                                                "emergency"))
      vw_adtc <<- dplyr::tbl(cnx, 
                            dbplyr::in_schema("publish", 
                                              "admission_discharge"))
      
      
      
}


# function test: 
# setup_denodo()
