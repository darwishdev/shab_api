package repo

import (
	"database/sql"
	"shab/config"
	"shab/model"
	"shab/utils"

	"github.com/jinzhu/gorm"
)

type RoleRepo struct {
	db *gorm.DB
}

func NewRoleRepo(db *gorm.DB) RoleRepo {

	return RoleRepo{
		db: db,
	}
}

func (ur *RoleRepo) ListAll(active *bool, priceFrom int, priceTo int, name string) (*[]interface{}, error) {
	var resp []interface{}
	rows, err := ur.db.Raw("CALL RolesList(? , ? , ? , ?)", active, name, priceFrom, priceTo).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	err = scanRoleResut(rows, &resp, nil, nil)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}

func (ur *RoleRepo) Find(id *int) (*model.Role, error) {
	var resp model.Role
	row := ur.db.Raw("CALL RoleFind(?)", id).Row()
	err := scanRoleResut(nil, nil, row, &resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}
func (ur *RoleRepo) Edit(id *int, req *model.Role) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL RoleEdit(? , ? , ? ,? , ? , ? , ?)", id, req.Name, req.Img, req.Breif, req.Price, req.Color, req.Active).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}

func scanRoleResut(rows *sql.Rows, resp *[]interface{}, row *sql.Row, rec *model.Role) error {
	if row != nil {
		err := row.Scan(
			&rec.Id,
			&rec.Name,
			&rec.Img,
			&rec.Breif,
			&rec.Price,
			&rec.Color,
			&rec.Active,
		)
		if err != nil {
			utils.NewError(err)
			return err
		}
		rec.Img = config.Config("BASE_URL") + rec.Img
	}
	if rows != nil {
		for rows.Next() {
			var record model.Role
			err := rows.Scan(
				&record.Id,
				&record.Name,
				&record.Img,
				&record.Breif,
				&record.Price,
				&record.Color,
				&record.Active,
			)
			if err != nil {
				utils.NewError(err)
				return err
			}
			record.Img = config.Config("BASE_URL") + record.Img
			*resp = append(*resp, record)
		}
	}
	return nil
}

func (ur *RoleRepo) ListAllFeatures() (*[]model.Feature, error) {
	var resp []model.Feature
	rows, err := ur.db.Raw("CALL FeaturesListAll()").Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var rec model.Feature
		rows.Scan(
			&rec.Id,
			&rec.Name,
			&rec.Breif,
			&rec.Level,
		)
		resp = append(resp, rec)
	}
	return &resp, nil
}

func (ur *RoleRepo) ListFeaturesByRole(role *int, name string) (*[]interface{}, error) {
	var resp []interface{}
	rows, err := ur.db.Raw("CALL FeaturesListByRole(? , ? )", role, name).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var rec model.Feature
		rows.Scan(
			&rec.Id,
			&rec.Name,
			&rec.Breif,
			&rec.Level,
		)
		resp = append(resp, rec)
	}
	return &resp, nil
}

func (ur *RoleRepo) FindFeatureById(id *int) (*model.Feature, error) {
	var resp model.Feature
	err := ur.db.Raw("CALL FeaturesFindById(?)", id).Row().Scan(
		&resp.Id,
		&resp.Name,
		&resp.Breif,
		&resp.Level,
	)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}

func (ur *RoleRepo) EditAddFeature(req *model.Feature) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL FeaturesEditAdd(? , ? , ? , ?)", req.Id, req.Name, req.Breif, req.Level).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}
