package middleware

import (
	"fmt"
	"net/http"

	"github.com/dgrijalva/jwt-go"
	"github.com/labstack/echo/v4"
)

type (
	JWTConfig struct {
		Skipper    Skipper
		SigningKey interface{}
	}
	Skipper      func(c echo.Context) bool
	jwtExtractor func(echo.Context) (string, error)
)

var (
	ErrJWTMissing = echo.NewHTTPError(http.StatusUnauthorized, "un authorized")
	ErrJWTInvalid = echo.NewHTTPError(http.StatusForbidden, "invalid or expired jwt")
)

func JWT(key interface{}) echo.MiddlewareFunc {
	c := JWTConfig{}
	c.SigningKey = key
	return JWTWithConfig(c)
}

type Error struct {
	Errors map[string]interface{} `json:"errors"`
}

func NewError(err error) Error {
	e := Error{}
	e.Errors = make(map[string]interface{})
	switch v := err.(type) {
	case *echo.HTTPError:
		e.Errors["body"] = v.Message
	default:
		e.Errors["body"] = v.Error()
	}
	return e
}

func JWTWithConfig(config JWTConfig) echo.MiddlewareFunc {
	extractor := jwtFromHeader("Authorization", "Bearer")
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			auth, err := extractor(c)
			if err != nil {
				if config.Skipper != nil {
					if config.Skipper(c) {
						return next(c)
					}
				}
				return c.JSON(http.StatusUnauthorized, NewError(err))
			}
			token, err := jwt.Parse(auth, func(token *jwt.Token) (interface{}, error) {
				if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
				}
				return config.SigningKey, nil
			})
			if err != nil {
				return c.JSON(http.StatusForbidden, NewError(ErrJWTInvalid))
			}
			if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
				userID := uint(claims["id"].(float64))
				c.Set("user", userID)
				return next(c)
			}
			return c.JSON(http.StatusForbidden, NewError(ErrJWTInvalid))
		}
	}
}

// jwtFromHeader returns a `jwtExtractor` that extracts token from the request header.
func jwtFromHeader(header string, authScheme string) jwtExtractor {
	return func(c echo.Context) (string, error) {
		auth := c.Request().Header.Get(header)
		l := len(authScheme)
		if len(auth) > l+1 && auth[:l] == authScheme {
			return auth[l+1:], nil
		}
		return "", ErrJWTMissing
	}
}
