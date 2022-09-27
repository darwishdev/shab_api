package repo

import (
	"fmt"
	"shab/config"
	"shab/model"
	"shab/utils"

	"github.com/jinzhu/gorm"
)

type ProjectRepo struct {
	db *gorm.DB
}

func NewProjectRepo(db *gorm.DB) ProjectRepo {
	return ProjectRepo{
		db: db,
	}
}

func (pr *ProjectRepo) ListFeatured() (*[]model.ProjectList, error) {
	var resp []model.ProjectList
	rows, err := pr.db.Raw("CALL ProjectsListFeatured();").Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var rec model.ProjectList
		rows.Scan(
			&rec.Id,
			&rec.Title,
			&rec.Logo,
			&rec.Img,
		)
		rec.Img = config.Config("BASE_URL") + rec.Img
		rec.Logo = config.Config("BASE_URL") + rec.Logo
		resp = append(resp, rec)
	}
	return &resp, nil
}

func (pr *ProjectRepo) ListByCategoryUserSearch(category uint64, city uint64, user uint64, search string, userName string, status string) (*[]interface{}, error) {
	var resp []interface{}
	rows, err := pr.db.Raw("CALL ProjectsListByCategoryUserSearch(? , ? , ? , ? , ? , ?);", category, city, user, search, userName, status).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var rec model.ProjectList
		err = rows.Scan(
			&rec.Id,
			&rec.Title,
			&rec.UserName,
			&rec.CategoryName,
			&rec.CityName,
			&rec.Status,
			&rec.Logo,
			&rec.Img,
		)
		if err != nil {
			utils.NewError(err)
			return nil, err
		}
		rec.Img = config.Config("BASE_URL") + rec.Img
		rec.Logo = config.Config("BASE_URL") + rec.Logo

		resp = append(resp, rec)
	}
	return &resp, nil
}

func (pr *ProjectRepo) Delete(id uint64) (*int, error) {
	var resp int
	err := pr.db.Raw("CALL ProjectDelete(?);", id).Row().Scan(
		&resp,
	)

	if err != nil {
		utils.NewError(err)
		return nil, err
	}

	return &resp, nil
}

func (pr *ProjectRepo) ProjectRead(id uint64) (*model.Project, error) {
	var project model.Project
	err := pr.db.Raw("CALL ProjectRead(?);", id).Row().Scan(
		&project.UserName,
		&project.CategoryName,
		&project.CatId,
		&project.City,
		&project.CityId,
		&project.Title,
		&project.Img,
		&project.Logo,
		&project.Fund,
		&project.Status,
		&project.Breif,
		&project.Imgs,
		&project.Location,
		&project.Phone,
		&project.File,
		&project.Email,
		&project.Featured,
		&project.Website,
		&project.Instagram,
		&project.Twitter,
	)

	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	project.Img = config.Config("BASE_URL") + project.Img
	project.Logo = config.Config("BASE_URL") + project.Logo
	project.File = config.Config("BASE_URL") + project.File

	fmt.Println(project)
	fmt.Println("project")

	return &project, nil
}

func (pr *ProjectRepo) ProjectsCreate(req *model.ProjectCreateReq) (uint, error) {
	var id uint
	err := pr.db.Raw("CALL ProjectsCreate(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,? , ? , ?);",
		req.Userid,
		req.CatId,
		req.CityId,
		req.Title,
		req.Status,
		req.Img,
		req.Imgs,
		req.Logo,
		req.Fund,
		req.Breif,
		req.Location,
		req.Phone,
		req.File,
		req.Email,
		req.Website,
		req.Instagram,
		req.Twitter,
		req.Featured,
		req.Active,
	).Row().Scan(&id)

	if err != nil {
		return 0, err
	}

	return id, nil
}

func (pr *ProjectRepo) ProjectsUpdate(req *model.ProjectCreateReq, id *int) (uint, error) {
	var resp uint
	err := pr.db.Raw("CALL ProjectUpdate(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",
		id,
		req.CatId,
		req.CityId,
		req.Title,
		req.Status,
		req.Img,
		req.Imgs,
		req.Logo,
		req.Fund,
		req.Breif,
		req.Location,
		req.Phone,
		req.File,
		req.Email,
		req.Website,
		req.Instagram,
		req.Twitter,
		req.Featured,
		req.Active,
	).Row().Scan(&resp)

	if err != nil {
		return 0, err
	}

	return resp, nil
}
