package repo

import (
	"shab/utils"

	"github.com/jinzhu/gorm"
)

type GlobalRepo struct {
	db *gorm.DB
}

func NewGlobalRepo(db *gorm.DB) GlobalRepo {

	return GlobalRepo{
		db: db,
	}
}

func (ur *GlobalRepo) Delete(table *string, id *int) (*bool, error) {
	var resp bool
	err := ur.db.Raw("CALL DeleteRecord(? , ?)", table, id).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}
