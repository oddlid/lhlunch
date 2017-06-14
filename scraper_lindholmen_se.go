/*
Quick and dirty scraper hack for replacing the Perl scraper, as lindholmen.se now has changed their html,
and the scraping needs to be updated anyways.
Trying to pull everything in one swoop from https://www.lindholmen.se/pa-omradet/dagens-lunch
- Odd, 2017-06-14 08:58:11
*/

package main

import (
	"encoding/json"
	//"fmt"
	"github.com/PuerkitoBio/goquery"
	log "github.com/Sirupsen/logrus"
	"io"
)

type Dish struct {
	Name  string `json:"name"`
	Desc  string `json:"desc"`
	Price string `json:"price"`
}

type Restaurant struct {
	Name   string `json:"name"`
	Url    string `json:"url"`
	Dishes []Dish `json:"dishes"`
	Date   int64  `json:"date"`
}

type Restaurants []Restaurant

func (r Restaurant) Add(d Dish) {
	r.Dishes = append(r.Dishes, d)
}

func (rs Restaurants) DumpJSON(w io.Writer, indent bool) (int, error) {
	var jbytes []byte
	var err error

	if !indent {
		jbytes, err = json.Marshal(rs)
	} else {
		jbytes, err = json.MarshalIndent(rs, "", "  ")
	}
	if err != nil {
		return 0, err
	}
	return w.Write(jbytes)
}

func scrape(url string) (Restaurants, error) {
	csel := []string{
		"h3.title",
		"div.table-list__row",
		"span.dish-name",
		"strong",
		"div.table-list__column.table-list__column--price",
	}

	rs := Restaurants{}

	doc, err := goquery.NewDocument(url)
	if err != nil {
		log.Fatal(err)
	}

	doc.Find(csel[0]).Each(func(i int, sel1 *goquery.Selection) {
		rname := sel1.Find("a").Text()
		log.Debugf("Restaurant: %q", rname)
		log.Debug("Dish: gris")
		//sel1.SiblingsFiltered(csel[1]).Each(func(j int, sel2 *goquery.Selection) {
		//	//dname := sel2.Find(csel[2]).Find(csel[3]).Text()
		//	ddesc := sel2.Find(csel[2]).Text()
		//	log.Debugf("Dish: %q", ddesc)
		//})
	})

	return rs, nil
}

func testscrape() {
	log.SetLevel(log.DebugLevel)
	log.SetFormatter(&log.TextFormatter{
		DisableTimestamp: false,
		FullTimestamp:    true,
	})

	scrape("http://localhost")
}

func main() {
	testscrape()
}
