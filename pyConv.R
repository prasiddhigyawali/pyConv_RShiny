library(shiny)
library(DT)
library(RColorBrewer)
library(reticulate)

reticulate::py_install("pandas")
reticulate::source_python("data_cleaning.py")

df <- open_df("https://raw.githubusercontent.com/futres/fovt-data-mapping/master/Scripts/pythonConversion/1987to2019_Cougar_Weight_Length_Public_Request.csv")
df <- remove_rcna(df)
df <- yc(df)
df <- verLocal(df,c("Management Unit", "County"))
arr <- c("Management Unit", "County")
print(arr)
paste(cat(colcheck(df)))


