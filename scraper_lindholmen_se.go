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
	"github.com/urfave/cli"
	"io"
	"os"
	"strings"
	"time"
)

const (
	VERSION string = "2017-06-16"
	DEF_URL string = "https://www.lindholmen.se/pa-omradet/dagens-lunch"
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
		log.Error("Error marshalling to JSON")
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
	var num_restaurants int
	var num_dishes int

	rs := Restaurants{}

	t_start := time.Now()
	log.Infof("Starting scrape of %q @ %s", url, t_start.Format(time.RFC3339))
	doc, err := goquery.NewDocument(url)
	if err != nil {
		return rs, err
	}

	doc.Find(csel[0]).Each(func(i int, sel1 *goquery.Selection) {
		rname := sel1.Find("a").Text()
		log.Debugf("Found restaurant: %q", rname)

		r := &Restaurant{Name: rname, Date: time.Now().Unix(), Url: url}
		num_restaurants++

		sel1.NextFilteredUntil(csel[1], csel[0]).Each(func(j int, sel2 *goquery.Selection) {
			dname := strings.TrimSpace(sel2.Find(csel[2]).Find(csel[3]).Text())
			ddesc := strings.TrimSpace(strings.Replace(sel2.Find(csel[2]).Text(), dname, "", 1))
			dprice := strings.TrimSpace(strings.Replace(sel2.Find(csel[4]).Text(), "kr", "", 1))
			r.Add(Dish{Name: dname, Desc: ddesc, Price: dprice})
			num_dishes++

			log.Debugf("Found dish: %q", dname)
		})

		rs = append(rs, *r)
	})
	log.Infof("Scrape done in %f seconds", time.Duration(time.Now().Sub(t_start)).Seconds())
	log.Infof("Parsed %d restaurants with %d dishes in total", num_restaurants, num_dishes)

	return rs, nil
}

func entryPoint(ctx *cli.Context) error {
	url := ctx.String("url")
	logfile := ctx.String("log-file")
	outfile := ctx.String("output")
	indent := ctx.Bool("indent-output")

	if url == "" {
		return cli.NewExitError("No URL given", 64)
	}

	if logfile != "" {
		lf, err := os.OpenFile(logfile, os.O_WRONLY|os.O_APPEND|os.O_CREATE, 0660)
		if err != nil {
			log.Errorf("Failed to open logfile %q", logfile)
			return cli.NewExitError(err.Error(), 74)
		}
		defer lf.Close()
		log.SetOutput(lf)
	} else {
		log.SetOutput(os.Stderr)
	}

	var ofile *os.File
	var err error
	if outfile != "" {
		ofile, err = os.OpenFile(outfile, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0660)
		if err != nil {
			log.Errorf("Failed to open output file %q", outfile)
			return cli.NewExitError(err.Error(), 74)
		}
		defer ofile.Close()
	} else {
		ofile = os.Stdout
	}

	rs, err := scrape(url)
	if err != nil {
		return cli.NewExitError(err.Error(), 69)
	}

	nbytes, err := rs.DumpJSON(ofile, indent)
	if err != nil {
		log.Errorf("Failed to write output to %q", outfile)
		return cli.NewExitError(err.Error(), 74)
	}

	log.Infof("%d bytes written to %q", nbytes, ofile.Name())

	return nil
}

func main() {
	app := cli.NewApp()
	app.Name = "Lindholmen Lunch Scraper"
	app.Version = VERSION
	app.Authors = []cli.Author{
		cli.Author{
			Name:  "Odd E. Ebbesen",
			Email: "oddebb@gmail.com",
		},
	}
	app.Usage = "Scrape lindholmen.se for todays lunch and parse to JSON"
	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:  "url, u",
			Usage: "`URL` to scrape",
			Value: DEF_URL,
		},
		cli.StringFlag{
			Name:  "output, o",
			Usage: "Save output in `FILE`. Will save to STDOUT if not given.",
		},
		cli.BoolFlag{
			Name:  "indent-output, i",
			Usage: "Print indented and readable JSON output",
		},
		cli.StringFlag{
			Name:  "log-file, f",
			Usage: "Log to `FILE`. Will log to STDERR if not given.",
		},
		cli.StringFlag{
			Name:  "log-level, l",
			Value: "error",
			Usage: "Log `level` (options: debug, info, warn, error, fatal, panic)",
		},
		cli.BoolFlag{
			Name:  "debug, d",
			Usage: "Run in debug mode",
		},
	}

	app.Before = func(c *cli.Context) error {
		log.SetOutput(os.Stderr)
		level, err := log.ParseLevel(c.String("log-level"))
		if err != nil {
			log.Fatal(err.Error())
		}
		log.SetLevel(level)
		if !c.IsSet("log-level") && !c.IsSet("l") && c.Bool("debug") {
			log.SetLevel(log.DebugLevel)
		}
		log.SetFormatter(&log.TextFormatter{
			DisableTimestamp: false,
			FullTimestamp:    true,
		})
		return nil
	}

	app.Action = entryPoint
	app.Run(os.Args)
}
