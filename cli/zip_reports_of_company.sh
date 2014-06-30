coffee zip_reports_of_company.coffee $1 | sh
zip -j $1.zip $1/*
rm -rf $1
