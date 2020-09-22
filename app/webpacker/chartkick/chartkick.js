require('chartkick')
require('chart.js/')

import Chartkick from "chartkick"
import Chart from "chart.js"

Chartkick.use(Chart)

new Chartkick.LineChart("chart-1", JSON.parse('welcome/index.json'))
// source: 'index.json'