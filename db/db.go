package db

import (
	"fmt"
	"shab/config"

	"github.com/jinzhu/gorm"
	_ "gorm.io/driver/mysql"
)

var (
	DB *gorm.DB
)

func New() (*gorm.DB, error) {
	conStr := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local", config.Config("DB_USER"), config.Config("DB_PASSWORD"), config.Config("DB_HOST"), config.Config("DB_PORT"), config.Config("DB_NAME"))
	DB, err := gorm.Open("mysql", conStr)
	if err != nil {
		return nil, err
	}
	DB.LogMode(true)
	return DB, nil
}
