package repo

import (
	"shab/config"
	"shab/model"
	"shab/utils"

	"github.com/jinzhu/gorm"
)

type ArticleRepo struct {
	db *gorm.DB
}

func NewArticleRepo(db *gorm.DB) ArticleRepo {
	return ArticleRepo{
		db: db,
	}
}

func (ar *ArticleRepo) ArticleCreate(req *model.ArticleCreateReq) (uint, error) {
	var id uint
	err := ar.db.Raw("CALL ArticleCreate(?,? ,?,?,?,?,?);",
		req.UserId,
		req.CatId,
		req.ViewsCounter,
		req.Title,
		req.Img,
		req.Content,
		req.Status,
	).Row().Scan(&id)
	if err != nil {
		return 0, err
	}
	return id, nil
}

func (ar *ArticleRepo) ArticleUpdate(id *int, req *model.ArticleCreateReq) (*uint, error) {
	var resp uint
	err := ar.db.Raw("CALL ArticleUpdate(?,?,?,?,?,?,?,?);",
		id,
		req.UserId,
		req.CatId,
		req.ViewsCounter,
		req.Title,
		req.Img,
		req.Content,
		req.Status,
	).Row().Scan(&resp)
	if err != nil {
		return nil, err
	}
	return &resp, nil
}

func (ar *ArticleRepo) ListByCategoryUserSearch(req *model.ArticlesListReq) (*[]interface{}, error) {
	var articles []interface{}
	rows, err := ar.db.Raw("CALL ArticleListByCategoryUserSearch(? , ? , ? , ? , ?);",
		req.Category,
		req.UserName,
		req.DateFrom,
		req.DateTo,
		req.Search,
	).Rows()
	defer rows.Close()
	for rows.Next() {
		var article model.ArticleList
		rows.Scan(
			&article.Id,
			&article.CategoryName,
			&article.ViewsCounter,
			&article.UserName,
			&article.UserImg,
			&article.Title,
			&article.Img,
			&article.Views,
			&article.Published_at,
		)
		// article.Img = config.Config("BASE_URL") + article.Img
		// article.UserImg = config.Config("BASE_URL") + article.UserImg

		articles = append(articles, article)

	}
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &articles, nil
}

func (ar *ArticleRepo) ArticleRead(id uint64) (*model.Article, error) {
	var article model.Article
	err := ar.db.Raw("CALL ArticleRead(?);", id).Row().Scan(
		&article.Id,
		&article.UserId,
		&article.CatId,
		&article.ViewsCounter,
		&article.UserName,
		&article.UserImg,
		&article.CategoryName,
		&article.Title,
		&article.Img,
		&article.Views,
		&article.Status,
		&article.Content,
		&article.Created_at,
		&article.Published_at,
	)
	article.Img = config.Config("BASE_URL") + article.Img
	article.UserImg = config.Config("BASE_URL") + article.UserImg

	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &article, nil
}

func (ar *ArticleRepo) ArticleDelete(id uint64) (*int, error) {
	var resp int
	err := ar.db.Raw("CALL ArticleDelete(?);", id).Row().Scan(
		&resp,
	)
	if err != nil {
		utils.NewError(err)
		return nil, err
	}
	return &resp, nil
}
