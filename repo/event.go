package repo

import (
	"database/sql"
	"shab/config"
	"shab/model"
	"shab/utils"
	"strings"

	"github.com/jinzhu/gorm"
)

type EventRepo struct {
	db *gorm.DB
}

func NewEventRepo(db *gorm.DB) EventRepo {
	return EventRepo{
		db: db,
	}
}

func (ur *EventRepo) ListAll(req *model.EventListReq) (*[]interface{}, error) {
	rows, err := ur.db.Raw("CALL EventsList(? , ? ,? , ? , ? , ? , ? , ?)",
		req.Featured,
		req.Title,
		req.Status,
		req.Category,
		req.DateFrom,
		req.DateTo,
		req.PriceFrom,
		req.PriceTo,
	).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	result, err := scanResult(rows)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return result, nil
}
func (ur *EventRepo) Read(id int64) (*model.Event, error) {
	var event model.Event
	err := ur.db.Raw("CALL EventRead(?)", id).Row().Scan(
		&event.Id,
		&event.Title,
		&event.Img,
		&event.Breif,
		&event.Day,
		&event.Month,
		&event.Year,
		&event.Date,
		&event.Price,
		&event.Featured,
		&event.Created_at,
		&event.CatId,
		&event.CatName,
		&event.Video,
	)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	event.Img = config.Config("BASE_URL") + event.Img
	// layout := "2022-04-09"
	event.Date = strings.Split(event.Date, "T")[0]
	return &event, nil
}

func (ur *EventRepo) Edit(id *int, req *model.EventRequest) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL EventEdit(? , ? , ? , ? , ? , ? , ? , ? , ? )",
		id,
		req.Title,
		req.Img,
		req.Video,
		req.Breif,
		req.Date,
		req.Price,
		req.Featured,
		req.CatId,
	).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}

	return &resp, nil
}

func (ur *EventRepo) Create(req *model.EventRequest) (*int, error) {
	var resp int
	err := ur.db.Raw("CALL EventCreate(? , ? , ? , ? , ? , ? , ? , ? )",
		req.Title,
		req.Img,
		req.Video,
		req.Breif,
		req.Date,
		req.Price,
		req.Featured,
		req.CatId,
	).Row().Scan(&resp)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}

	return &resp, nil
}

func (er *EventRepo) ListFeatured() (*[]interface{}, error) {
	// req := new(model.EventListReq)
	var req model.EventListReq
	rows, err := er.db.Raw("CALL EventsList(1 , ? ,? , ? , ? , ? , ? , ?)",
		req.Title,
		req.Status,
		req.Category,
		req.DateFrom,
		req.DateTo,
		req.PriceFrom,
		req.PriceTo,
	).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()

	result, err := scanResult(rows)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return result, nil
}

func (er *EventRepo) ListByCategorySearch(category uint, search string) (*[]interface{}, error) {
	rows, err := er.db.Raw("CALL EventsListByCategorySearch(? , ?);", category, search).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	result, err := scanResult(rows)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return result, nil
}

func scanResult(rows *sql.Rows) (*[]interface{}, error) {
	var resp []interface{}
	for rows.Next() {
		var rec model.Event
		rows.Scan(
			&rec.Id,
			&rec.Title,
			&rec.Img,
			&rec.Breif,
			&rec.Day,
			&rec.Month,
			&rec.Year,
			&rec.Price,
			&rec.Featured,
			&rec.Created_at,
			&rec.CatName,
			&rec.CatId,
		)
		rec.Img = config.Config("BASE_URL") + rec.Img

		resp = append(resp, rec)
	}

	return &resp, nil
}
