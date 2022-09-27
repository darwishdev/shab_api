package repo

import (
	"database/sql"
	"shab/model"
	"shab/utils"

	"github.com/jinzhu/gorm"
)

type CityRepo struct {
	db *gorm.DB
}

func NewCityRepo(db *gorm.DB) CityRepo {
	return CityRepo{
		db: db,
	}
}

func (ur *CityRepo) CityListAll() (*[]model.City, error) {
	rows, err := ur.db.Raw("CALL CityListAll()").Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	result, err := scanCityResult(rows)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return result, nil
}

func (ur *CityRepo) CityRead(id *uint64) (*model.City, error) {
	var resp model.City
	err := ur.db.Raw("CALL CityFind(?)", *id).Row().Scan(&resp.Id, &resp.Name)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}

func (ur *CityRepo) CityCreate(city *model.City) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL CityCreate(?)", city.Name).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}

func (ur *CityRepo) CityUpdate(city *model.City) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL CityUpdate(? , ?)", city.Id, city.Name).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}

func scanCityResult(rows *sql.Rows) (*[]model.City, error) {
	var resp []model.City
	for rows.Next() {
		var rec model.City
		rows.Scan(
			&rec.Id,
			&rec.Name,
		)
		resp = append(resp, rec)
	}

	return &resp, nil
}
