#!/usr/bin/env node --no-warnings

const assert = require("assert");
const { createReadStream, promises: fs } = require("fs");
const { join } = require("path");
const { argv } = require("process");

const lpad = (msg, amount) => {
  if (amount <= msg.length) {
    return msg;
  }
  return " ".repeat(amount - msg.length) + msg;
};

const getFilesInDir = async path => {
  let files = await fs.readdir(path);
  files = files.map(fName => join(path, fName));
  const filesAndStats = await Promise.all(
    files.map(fName => fs.stat(fName).then(stats => [fName, stats]))
  );
  return filesAndStats
    .filter(([_, stats]) => stats.isFile())
    .map(([fName, _]) => fName);
};

const countLinesInFile = async path => {
  const fileStream = createReadStream(path, { encoding: "utf8" });
  let count = 0;
  for await (const buffer of fileStream) {
    for (const c of buffer) {
      if (c === "\n") {
        count++;
      }
    }
  }
  return count;
};

let countLinesInDir = async path => {
  let files = await getFilesInDir(path);
  return Promise.all(
    files.map(async fName => ({
      path: fName,
      count: await countLinesInFile(fName)
    }))
  );
};

const printLineCount = ({ path, count }) => {
  console.log(`${lpad(count.toString(), 10)} ${path}`);
};

let main = async () => {
  const start = Date.now();
  assert.ok(
    argv.length >= 2,
    "Process was somehow not called with node and script args"
  );
  const dir = argv[2] || ".";
  const lineCounts = await countLinesInDir(dir);
  lineCounts.sort(
    (a, b) => (a.count > b.count ? -1 : a.count === b.count ? 0 : 1)
  );
  let total = 0;
  for (const lineCount of lineCounts) {
    printLineCount(lineCount);
    total += lineCount.count;
  }
  printLineCount({ path: "[TOTAL]", count: total });
  const end = Date.now();
  const elapsed = end - start;
  console.log(`Took ${elapsed}ms`);
};

main();
