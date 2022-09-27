package utils

import (
	"fmt"
	"reflect"
	"strconv"

	"github.com/360EntSecGroup-Skylar/excelize"
)

func GenerateExcel(data []interface{}) string {
	print("data")
	fileName := "assets/alshab-data.xlsx"
	// print(len(data))
	f := excelize.NewFile()
	// Create a new sheet.
	index := f.NewSheet("Sheet")
	v := reflect.ValueOf(data[0])
	typeOfS := v.Type()
	var letters = [28]string{"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
	for i := 0; i < v.NumField(); i++ {
		f.SetCellValue("Sheet", letters[i]+"1", typeOfS.Field(i).Name)
	}
	f.SetActiveSheet(index)

	for i := 0; i < len(data); i++ {
		item := reflect.ValueOf(data[i])
		for j := 0; j < item.NumField(); j++ {
			f.SetCellValue("Sheet", letters[j]+strconv.Itoa(i+2), item.Field(j).Interface())
		}
	}
	// Save xlsx file by the given path.
	if err := f.SaveAs(fileName); err != nil {
		println(err.Error())
	}
	return fileName
}

func ReadExcel(file string) ([]interface{}, error) {
	var resp []interface{}
	f, err := excelize.OpenFile("Book1.xlsx")
	if err != nil {
		fmt.Println(err)
		return nil, err
	}
	defer func() {
		// Close the spreadsheet.
		// if err := f.Close(); err != nil {
		// 	fmt.Println(err)
		// }
	}()
	// Get value from cell by given worksheet name and cell reference.
	cell := f.GetCellValue("Sheet1", "B2")

	fmt.Println(cell)
	// Get all the rows in the Sheet1.
	rows := f.GetRows("Sheet1")
	for _, row := range rows {
		for _, colCell := range row {
			fmt.Print(colCell, "\t")
		}
		fmt.Println()
	}
	return resp, nil
}
