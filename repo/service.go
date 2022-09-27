package repo

import (
	"shab/model"
	"shab/utils"

	"github.com/jinzhu/gorm"
)

type ServiceRepo struct {
	db *gorm.DB
}

func NewServiceRepo(db *gorm.DB) ServiceRepo {

	return ServiceRepo{
		db: db,
	}
}

func (ur *ServiceRepo) ListAllServicces(name string) (*[]interface{}, error) {
	var resp []interface{}
	rows, err := ur.db.Raw("CALL ServicesListAll(?)", name).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var rec model.Service
		rows.Scan(
			&rec.Id,
			&rec.Name,
			&rec.Icon,
		)
		resp = append(resp, rec)
	}
	return &resp, nil
}

func (ur *ServiceRepo) Find(id *int) (*model.Service, error) {
	var resp model.Service
	err := ur.db.Raw("CALL ServicesFindById(?)", id).Row().Scan(
		&resp.Id,
		&resp.Name,
		&resp.Icon,
	)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}

func (ur *ServiceRepo) CreateService(req model.Service) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL ServiceCreate(? , ?) ", req.Name, req.Icon).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return &resp, err
	}
	return &resp, nil
}

func (ur *ServiceRepo) UpdateService(req model.Service) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL ServiceUpdate(?,? , ?) ", req.Id, req.Name, req.Icon).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return &resp, err
	}
	return &resp, nil
}

func (ur *ServiceRepo) FindPendingSerivce(id uint64) (*model.ServiceReq, error) {
	var resp model.ServiceReq
	err := ur.db.Raw("CALL SerivcesPendingFind(?) ", id).Row().Scan(
		&resp.Id,
		&resp.Name,
		&resp.Email,
		&resp.Phone,
		&resp.Breif,
		&resp.CreatedAt,
	)
	if err != nil {
		utils.NewError(err)
		return &resp, err
	}
	return &resp, nil
}

func (ur *ServiceRepo) DeleteService(id string) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL ServiceDelete(?) ", id).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return &resp, err
	}
	return &resp, nil
}
