#!/usr/bin/env node
'use strict'
import util from 'node:util'
import cp from 'node:child_process'
import {checkbox} from '@inquirer/prompts'
const exec = util.promisify(cp.exec);

const {stdout} = await exec(`git for-each-ref --sort=committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'`)
const branches = stdout.split('\n')
  .filter(Boolean)
  .map((line) => {
    const [date, branch] = line.split(' ')
    return {
      name: `${date} ${branch}`,
      value: branch
    }
  })

const choices = await checkbox({
  message: 'Select branches to delete',
  choices: branches
}).catch((err) => {
  console.log(err.message)
  process.exit(1)
})

if (!choices.length) {
  console.log('No branches selected')
  process.exit(0)
}

const res = await exec(`git branch -D ${choices.join(' ')}`)
if (res.stderr) console.error(res.stderr)
if (res.stdout) console.log(res.stdout)
