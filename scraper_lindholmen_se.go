/*
Quick and dirty scraper hack for replacing the Perl scraper, as lindholmen.se now has changed their html,
and the scraping needs to be updated anyways.
Trying to pull everything in one swoop from https://www.lindholmen.se/pa-omradet/dagens-lunch
- Odd, 2017-06-14 08:58:11
*/

package main

import (
	"encoding/json"
	"github.com/PuerkitoBio/goquery"
	log "github.com/Sirupsen/logrus"
	"io"
	"os"
	"strings"
	"time"
)

type Dish struct {
	Name  string `json:"dish"`
	Desc  string `json:"desc"`
	Price string `json:"price"`
}

type Restaurant struct {
	Name   string `json:"name"`
	Url    string `json:"url,omitempty"`
	Dishes []Dish `json:"dishes"`
	Date   int64  `json:"date"`
}

type Restaurants []Restaurant

func (r *Restaurant) Add(d Dish) {
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
	jbytes = append(jbytes, '\n')
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
		return rs, err
	}

	doc.Find(csel[0]).Each(func(i int, sel1 *goquery.Selection) {
		rname := sel1.Find("a").Text()
		log.Debugf("Restaurant: %q", rname)

		r := &Restaurant{Name: rname, Date: time.Now().Unix(), Url: url}

		sel1.NextAllFiltered(csel[1]).Each(func(j int, sel2 *goquery.Selection) {
			dname := strings.TrimSpace(sel2.Find(csel[2]).Find(csel[3]).Text())
			ddesc := strings.TrimSpace(strings.Replace(sel2.Find(csel[2]).Text(), dname, "", 1))
			dprice := strings.TrimSpace(strings.Replace(sel2.Find(csel[4]).Text(), "kr", "", 1))
			log.Debugf("Dish: %q", ddesc)

			r.Add(Dish{Name: dname, Desc: ddesc, Price: dprice})
		})

		rs = append(rs, *r)
	})

	log.Debugf("%+v", rs)

	return rs, nil
}

func testscrape() {
	log.SetLevel(log.DebugLevel)
	//log.SetFormatter(&log.TextFormatter{
	//	DisableTimestamp: false,
	//	FullTimestamp:    true,
	//})

	rs, err := scrape("http://localhost")
	if err != nil {
		log.Fatal(err)
	}

	rs.DumpJSON(os.Stdout, false)
}

func main() {
	log.SetOutput(os.Stderr)
	log.SetLevel(log.ErrorLevel)

	//testscrape()

	rs, err := scrape(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}

	_, err = rs.DumpJSON(os.Stdout, false)
	if err != nil {
		log.Fatal(err)
	}
}
