package repo

import (
	"fmt"
	"shab/config"
	"shab/model"
	"shab/utils"
	"strings"

	"github.com/jinzhu/gorm"
)

type ConsltuntsRepo struct {
	db *gorm.DB
}

func NewConsultuntsRepo(db *gorm.DB) ConsltuntsRepo {
	return ConsltuntsRepo{
		db: db,
	}
}

func (ur *ConsltuntsRepo) ConsultuntsListAll(req *model.ConsultuntListReq) ([]interface{}, error) {
	rows, err := ur.db.Raw("CALL ConsultuntsListAll(? , ? , ? , ?);", req.IsTeam, req.Name, req.Title, req.Skills).Rows()
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	defer rows.Close()
	var resp []interface{}
	for rows.Next() {
		var rec model.Consultunt
		err = rows.Scan(
			&rec.Id,
			&rec.NameAr,
			&rec.Title,
			&rec.Skills,
			&rec.Image,
			&rec.IsTeam,
			&rec.Breif,
		)
		if err != nil {
			utils.NewError(err)
			return nil, err
		}
		rec.Skills = strings.TrimRight(rec.Skills, ",")

		rec.Image = config.Config("BASE_URL") + rec.Image
		resp = append(resp, rec)

	}
	if err != nil {
		utils.NewError(err)
		return nil, err
	}

	return resp, nil
}

func (ur *ConsltuntsRepo) ConsultuntsCreate(req *model.Consultunt) (string, error) {
	rows, err := ur.db.Raw("CALL ConsultuntsCreate(? , ? , ? ,? , ? , ?);",
		req.NameAr,
		req.Title,
		req.Skills,
		req.Image,
		req.IsTeam,
		req.Breif,
	).Rows()
	if err != nil {
		fmt.Println("error calling proc" + err.Error())
		utils.NewError(err)
		return "", err
	}
	defer rows.Close()

	return "created", nil
}
func (ur *ConsltuntsRepo) ConsultuntsUpdate(req *model.Consultunt) (string, error) {
	rows, err := ur.db.Raw("CALL ConsultuntsUpdate(? , ? , ?  , ? , ? ,? , ?);",
		req.Id,
		req.NameAr,
		req.Title,
		req.Skills,
		req.Image,
		req.IsTeam,
		req.Breif,
	).Rows()
	if err != nil {
		fmt.Println("error calling proc" + err.Error())
		utils.NewError(err)
		return "", err
	}
	defer rows.Close()

	return "updated", nil
}

func (ur *ConsltuntsRepo) ConsultuntById(id int) (*model.Consultunt, error) {
	var resp model.Consultunt

	err := ur.db.Raw("CALL ConsultuntById(?);", id).Row().Scan(
		&resp.Id,
		&resp.NameAr,
		&resp.Title,
		&resp.Skills,
		&resp.Image,
		&resp.IsTeam,
		&resp.Breif,
	)

	splitted := strings.Split(resp.Skills, ",")
	resp.Skills1 = splitted[0]
	resp.Skills2 = splitted[1]
	resp.Skills3 = splitted[2]
	fmt.Println("Asdasd")
	fmt.Println(resp.Skills1)
	fmt.Println(splitted)
	fmt.Println(splitted[0])
	fmt.Println(resp.Skills)
	if err != nil {
		fmt.Println("error calling proc" + err.Error())
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}
