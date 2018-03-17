---
title: "Execution of semi-transient workers"
author: "Will Landau"
date: "March 17, 2018"
output: html_document
---

## User input

- `workload`: a workload as described in the data structures chapter.
- `schedule`: a schedule as described in the data structures chapter.
- `workers`: maximum number of parallel workers to run at a time.
- `type`: `"transient"` in this case.
- `fun`: an apply-like function to create the workers.
- arguments to `fun`, passed with `...`.

## Initialize


