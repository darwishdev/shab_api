package repo

import (
	"shab/config"
	"shab/model"
	"shab/utils"

	"github.com/jinzhu/gorm"
)

type RichTextRepo struct {
	db *gorm.DB
}

func NewRichTextRepo(db *gorm.DB) RichTextRepo {
	return RichTextRepo{
		db: db,
	}
}

func (ur *RichTextRepo) ListByGroup(group uint) (*[]model.RichText, error) {
	var resp []model.RichText
	rows, err := ur.db.Raw("CALL RichTextListByGroupOrKey(? , ?);", group, nil).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var rec model.RichText
		rows.Scan(
			&rec.Value,
			&rec.Title,
			&rec.Image,
			&rec.Icon,
		)
		rec.Image = config.Config("BASE_URL") + rec.Image

		resp = append(resp, rec)
	}
	return &resp, nil
}

func (ur *RichTextRepo) Update(id *int, req *model.RichText) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL RichTextUpdate(? , ? , ? , ? , ?);", id, req.Title, req.Value, req.Icon, req.Image).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}
func (ur *RichTextRepo) GetById(id int) (*model.RichText, error) {
	var rec model.RichText
	err := ur.db.Raw("CALL RichTextListById(?);", id).Row().Scan(
		&rec.Id,
		&rec.Value,
		&rec.Title,
		&rec.Image,
		&rec.Icon,
	)
	rec.Image = config.Config("BASE_URL") + rec.Image

	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &rec, nil
}

func (ur *RichTextRepo) GetByKey(key string) (*model.RichText, error) {
	var rec model.RichText
	err := ur.db.Raw("CALL RichTextListByGroupOrKey(? , ?);", 0, key).Row().Scan(
		&rec.Value,
		&rec.Title,
		&rec.Image,
		&rec.Icon,
	)
	if rec.Image != "" {
		rec.Image = config.Config("BASE_URL") + rec.Image
	}

	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &rec, nil
}

func (ur *RichTextRepo) ListByPage(page string, title string, value string) (*[]interface{}, error) {
	var resp []interface{}
	rows, err := ur.db.Raw("CALL RichTextListByPage(? , ? , ?);", page, title, value).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var rec model.RichText
		rows.Scan(
			&rec.Id,
			&rec.Value,
			&rec.Title,
			&rec.Image,
			&rec.Icon,
		)
		if rec.Image != "" {
			rec.Image = config.Config("BASE_URL") + rec.Image
		}

		resp = append(resp, rec)
	}
	return &resp, nil
}
