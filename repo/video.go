package repo

import (
	"shab/config"
	"shab/model"
	"shab/utils"

	"github.com/jinzhu/gorm"
)

type VideoRepo struct {
	db *gorm.DB
}

func NewVideoRepo(db *gorm.DB) VideoRepo {
	return VideoRepo{
		db: db,
	}
}

func (ur *VideoRepo) ListByCategory(cat int, name string) (*[]interface{}, error) {
	var videos []interface{}
	rows, err := ur.db.Raw("CALL VideosListByCategory(? , ?);", cat, name).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var video model.Video
		err = rows.Scan(
			&video.Id,
			&video.Name,
			&video.CategoryName,
			&video.Url,
			&video.Image,
			&video.Breif,
			&video.CatId,
		)
		if err != nil {
			utils.NewError(err)
			return nil, err
		}
		video.Image = config.Config("BASE_URL") + video.Image

		videos = append(videos, video)

	}
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &videos, nil
}

func (ur *VideoRepo) Find(id *uint64) (*model.Video, error) {
	var video model.Video
	err := ur.db.Raw("CALL VideosRead(?);", id).Row().Scan(
		&video.Id,
		&video.Name,
		&video.Url,
		&video.Image,
		&video.Breif,
		&video.CatId,
		&video.CategoryName,
	)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &video, nil
}

func (ur *VideoRepo) Create(req model.VideoCreateReq) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL VideosCreate(? , ? , ? , ? , ?);",
		req.Name,
		req.Url,
		req.Image,
		req.Breif,
		req.CatId,
	).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}

func (ur *VideoRepo) Update(req model.Video) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL VideosUpdate(? , ? , ? , ? , ? , ? );",
		req.Id,
		req.Name,
		req.Url,
		req.Image,
		req.Breif,
		req.CatId,
	).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}

func (ur *VideoRepo) Delete(id uint64) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL VideosDelete(?);", id).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}
