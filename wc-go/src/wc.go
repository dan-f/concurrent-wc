package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"sort"
	"time"
)

type LineCount struct {
	filename string
	count    int
	err      error
}

func linesInFile(filename string) *LineCount {
	dat, err := ioutil.ReadFile(filename)
	if err != nil {
		return &LineCount{filename, -1, err}
	}
	count := 0
	for _, b := range dat {
		if b == '\n' {
			count += 1
		}
	}
	return &LineCount{filename, count, nil}
}

func getFilesInDir(path string) ([]string, error) {
	itemsInDir, err := ioutil.ReadDir(path)
	if err != nil {
		return nil, err
	}
	files := make([]string, 0)
	for _, f := range itemsInDir {
		if f.Mode().IsRegular() {
			files = append(files, filepath.Join(path, f.Name()))
		}
	}
	return files, nil
}

func check(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func main() {
	start := time.Now()
	args := os.Args[1:]
	dirPath := "./"
	if len(args) != 0 {
		dirPath = args[0]
	}
	files, err := getFilesInDir(dirPath)
	check(err)
	ch := make(chan *LineCount, len(files))
	lineCounts := make([]*LineCount, len(files))
	for _, filename := range files {
		go func(filename string) {
			ch <- linesInFile(filename)
		}(filename)
	}
	totalCount := 0
	for i, _ := range files {
		lineCount := <-ch
		if (*lineCount).err == nil {
			totalCount += (*lineCount).count
		}
		lineCounts[i] = lineCount
	}
	sort.Slice(lineCounts, func(i, j int) bool {
		return (*lineCounts[i]).count > (*lineCounts[j]).count
	})
	for _, lineCount := range lineCounts {
		count := (*lineCount).count
		filename := (*lineCount).filename
		fmt.Printf("%10v %s\n", count, filename)
	}
	fmt.Printf("%10v [TOTAL]\n", totalCount)
	elapsed := int64(time.Since(start) / time.Millisecond)
	fmt.Printf("Took %dms\n", elapsed)
}
