/**
 * Created by Ronan Williams on 19/10/2018.
 */

@IsTest
global with sharing class QuickbooksProfitAndLossCalloutMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {

        // mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
                '  "Header": {'+
                '    "Time": "2019-05-20T00:03:43-07:00",'+
                '    "ReportName": "ProfitAndLoss",'+
                '    "DateMacro": "this fiscal year-to-date",'+
                '    "ReportBasis": "Accrual",'+
                '    "StartPeriod": "2019-04-01",'+
                '    "EndPeriod": "2019-05-20",'+
                '    "SummarizeColumnsBy": "Total",'+
                '    "Currency": "GBP",'+
                '    "Option": ['+
                '      {'+
                '        "Name": "AccountingStandard",'+
                '        "Value": "UK"'+
                '      },'+
                '      {'+
                '        "Name": "NoReportData",'+
                '        "Value": "false"'+
                '      }'+
                '    ]'+
                '  },'+
                '  "Columns": {'+
                '    "Column": ['+
                '      {'+
                '        "ColTitle": "",'+
                '        "ColType": "Account",'+
                '        "MetaData": ['+
                '          {'+
                '            "Name": "ColKey",'+
                '            "Value": "account"'+
                '          }'+
                '        ]'+
                '      },'+
                '      {'+
                '        "ColTitle": "Total",'+
                '        "ColType": "Money",'+
                '        "MetaData": ['+
                '          {'+
                '            "Name": "ColKey",'+
                '            "Value": "total"'+
                '          }'+
                '        ]'+
                '      }'+
                '    ]'+
                '  },'+
                '  "Rows": {'+
                '    "Row": ['+
                '      {'+
                '        "Header": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Income"'+
                '            },'+
                '            {'+
                '              "value": ""'+
                '            }'+
                '          ]'+
                '        },'+
                '        "Rows": {'+
                '          "Row": ['+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "4.0 Revenue",'+
                '                    "id": "706"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "4000 Events Revenue",'+
                '                        "id": "645"'+
                '                      },'+
                '                      {'+
                '                        "value": "324740.31"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 4.0 Revenue"'+
                '                  },'+
                '                  {'+
                '                    "value": "324740.31"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "Summary": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Total Income"'+
                '            },'+
                '            {'+
                '              "value": "324740.31"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "type": "Section",'+
                '        "group": "Income"'+
                '      },'+
                '      {'+
                '        "Header": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Cost of Sales"'+
                '            },'+
                '            {'+
                '              "value": ""'+
                '            }'+
                '          ]'+
                '        },'+
                '        "Rows": {'+
                '          "Row": ['+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "5.0 Cost of sales",'+
                '                    "id": "661"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "5000 Events COS",'+
                '                        "id": "646"'+
                '                      },'+
                '                      {'+
                '                        "value": "87599.39"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 5.0 Cost of sales"'+
                '                  },'+
                '                  {'+
                '                    "value": "87599.39"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "Summary": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Total Cost of Sales"'+
                '            },'+
                '            {'+
                '              "value": "87599.39"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "type": "Section",'+
                '        "group": "COGS"'+
                '      },'+
                '      {'+
                '        "Summary": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Gross Profit"'+
                '            },'+
                '            {'+
                '              "value": "237140.92"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "type": "Section",'+
                '        "group": "GrossProfit"'+
                '      },'+
                '      {'+
                '        "Header": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Expenses"'+
                '            },'+
                '            {'+
                '              "value": ""'+
                '            }'+
                '          ]'+
                '        },'+
                '        "Rows": {'+
                '          "Row": ['+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "6.0 Payroll",'+
                '                    "id": "710"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6000 Gross Salaries",'+
                '                        "id": "711"'+
                '                      },'+
                '                      {'+
                '                        "value": "85639.17"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6001 Employers National Insurance",'+
                '                        "id": "712"'+
                '                      },'+
                '                      {'+
                '                        "value": "8829.24"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6002 Pension Costs",'+
                '                        "id": "713"'+
                '                      },'+
                '                      {'+
                '                        "value": "3745.62"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6003 Bonuses",'+
                '                        "id": "714"'+
                '                      },'+
                '                      {'+
                '                        "value": "4417.00"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6004 Death in Service Insurance",'+
                '                        "id": "715"'+
                '                      },'+
                '                      {'+
                '                        "value": "148.96"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6005 Private Health Insurance & Staff Healthcare",'+
                '                        "id": "716"'+
                '                      },'+
                '                      {'+
                '                        "value": "628.79"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6007 Freelancers",'+
                '                        "id": "718"'+
                '                      },'+
                '                      {'+
                '                        "value": "11380.00"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6009 Employee Gifts",'+
                '                        "id": "816"'+
                '                      },'+
                '                      {'+
                '                        "value": "270.45"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 6.0 Payroll"'+
                '                  },'+
                '                  {'+
                '                    "value": "115059.23"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "6.1 Management Fees",'+
                '                    "id": "720"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6100 Management Fee Live Group",'+
                '                        "id": "795"'+
                '                      },'+
                '                      {'+
                '                        "value": "0.00"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 6.1 Management Fees"'+
                '                  },'+
                '                  {'+
                '                    "value": "0.00"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "6.2 Training & Recruitment",'+
                '                    "id": "721"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6200 Training",'+
                '                        "id": "722"'+
                '                      },'+
                '                      {'+
                '                        "value": "22.95"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "6201 Recruitment",'+
                '                        "id": "723"'+
                '                      },'+
                '                      {'+
                '                        "value": "3155.76"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 6.2 Training & Recruitment"'+
                '                  },'+
                '                  {'+
                '                    "value": "3178.71"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "7.0 Property, Insurance and Infrastructure costs",'+
                '                    "id": "724"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7000 Rent",'+
                '                        "id": "725"'+
                '                      },'+
                '                      {'+
                '                        "value": "5269.23"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7001 Business Rates",'+
                '                        "id": "726"'+
                '                      },'+
                '                      {'+
                '                        "value": "1278.65"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7003 Utility Bills - Electricity, Gas, Water",'+
                '                        "id": "728"'+
                '                      },'+
                '                      {'+
                '                        "value": "38.38"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7101 Cleaning",'+
                '                        "id": "731"'+
                '                      },'+
                '                      {'+
                '                        "value": "1736.44"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7103 Other Property Repairs & Maintenance",'+
                '                        "id": "733"'+
                '                      },'+
                '                      {'+
                '                        "value": "416.00"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7200 Other Insurance",'+
                '                        "id": "796"'+
                '                      },'+
                '                      {'+
                '                        "value": "1241.99"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 7.0 Property, Insurance and Infrastructure costs"'+
                '                  },'+
                '                  {'+
                '                    "value": "9980.69"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "7.3 PR, Advertising & Marketing",'+
                '                    "id": "735"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7300 Client Hospitality",'+
                '                        "id": "736"'+
                '                      },'+
                '                      {'+
                '                        "value": "0.01"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7306 Gifts and Samples",'+
                '                        "id": "742"'+
                '                      },'+
                '                      {'+
                '                        "value": "491.92"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7309 Marketing services",'+
                '                        "id": "809"'+
                '                      },'+
                '                      {'+
                '                        "value": "4449.28"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 7.3 PR, Advertising & Marketing"'+
                '                  },'+
                '                  {'+
                '                    "value": "4941.21"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "7.3.5 Travel and subsistence",'+
                '                    "id": "745"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7350 Operational Meeting Expenses",'+
                '                        "id": "746"'+
                '                      },'+
                '                      {'+
                '                        "value": "394.80"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7351 Business Meals",'+
                '                        "id": "747"'+
                '                      },'+
                '                      {'+
                '                        "value": "670.07"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7352 Business Development - Meetings",'+
                '                        "id": "738"'+
                '                      },'+
                '                      {'+
                '                        "value": "3117.50"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7353 Business Travel (Trains, Parking, Taxis, Mileage)",'+
                '                        "id": "739"'+
                '                      },'+
                '                      {'+
                '                        "value": "2618.53"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7354 Business Accommodation",'+
                '                        "id": "822"'+
                '                      },'+
                '                      {'+
                '                        "value": "1953.13"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 7.3.5 Travel and subsistence"'+
                '                  },'+
                '                  {'+
                '                    "value": "8754.03"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "7.4 Motor expenses",'+
                '                    "id": "748"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7400 Vehicle Fuel",'+
                '                        "id": "749"'+
                '                      },'+
                '                      {'+
                '                        "value": "300.80"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7402 Vehicle Lease",'+
                '                        "id": "751"'+
                '                      },'+
                '                      {'+
                '                        "value": "943.40"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7403 Vehicle Insurance",'+
                '                        "id": "752"'+
                '                      },'+
                '                      {'+
                '                        "value": "240.40"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 7.4 Motor expenses"'+
                '                  },'+
                '                  {'+
                '                    "value": "1484.60"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "7.5 IT costs",'+
                '                    "id": "756"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7500 Domain Registration and Servers Maintenance",'+
                '                        "id": "757"'+
                '                      },'+
                '                      {'+
                '                        "value": "5207.11"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7501 Computer Software",'+
                '                        "id": "758"'+
                '                      },'+
                '                      {'+
                '                        "value": "4164.97"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7502 Computer Hardware",'+
                '                        "id": "759"'+
                '                      },'+
                '                      {'+
                '                        "value": "44.98"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7503 Computer Sundries",'+
                '                        "id": "760"'+
                '                      },'+
                '                      {'+
                '                        "value": "121.32"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7504 Internet lines",'+
                '                        "id": "761"'+
                '                      },'+
                '                      {'+
                '                        "value": "1181.62"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7505 Telephone - Mobile & Landline",'+
                '                        "id": "762"'+
                '                      },'+
                '                      {'+
                '                        "value": "2638.58"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 7.5 IT costs"'+
                '                  },'+
                '                  {'+
                '                    "value": "13358.58"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "7.6 Office costs",'+
                '                    "id": "763"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7600 Printing",'+
                '                        "id": "764"'+
                '                      },'+
                '                      {'+
                '                        "value": "307.82"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7601 Postage and Carriage",'+
                '                        "id": "765"'+
                '                      },'+
                '                      {'+
                '                        "value": "20.40"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7605 Office Costs (teas coffees etc)",'+
                '                        "id": "803"'+
                '                      },'+
                '                      {'+
                '                        "value": "504.75"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 7.6 Office costs"'+
                '                  },'+
                '                  {'+
                '                    "value": "832.97"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "7.7 Maintenance and Development of IP",'+
                '                    "id": "769"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7701 Maintenance of IP",'+
                '                        "id": "770"'+
                '                      },'+
                '                      {'+
                '                        "value": "4504.98"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 7.7 Maintenance and Development of IP"'+
                '                  },'+
                '                  {'+
                '                    "value": "4504.98"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "7.8 Legal & Professional Fees",'+
                '                    "id": "771"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7800 Legal Fees",'+
                '                        "id": "772"'+
                '                      },'+
                '                      {'+
                '                        "value": "325.00"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7801 Accountancy Fees",'+
                '                        "id": "773"'+
                '                      },'+
                '                      {'+
                '                        "value": "-500.00"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7803 Administration Fees",'+
                '                        "id": "807"'+
                '                      },'+
                '                      {'+
                '                        "value": "319.96"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 7.8 Legal & Professional Fees"'+
                '                  },'+
                '                  {'+
                '                    "value": "144.96"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "7.8.5 Other",'+
                '                    "id": "775"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7851 Subscriptions",'+
                '                        "id": "777"'+
                '                      },'+
                '                      {'+
                '                        "value": "287.95"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 7.8.5 Other"'+
                '                  },'+
                '                  {'+
                '                    "value": "287.95"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "Summary": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Total Expenses"'+
                '            },'+
                '            {'+
                '              "value": "162527.91"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "type": "Section",'+
                '        "group": "Expenses"'+
                '      },'+
                '      {'+
                '        "Summary": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Net Operating Income"'+
                '            },'+
                '            {'+
                '              "value": "74613.01"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "type": "Section",'+
                '        "group": "NetOperatingIncome"'+
                '      },'+
                '      {'+
                '        "Header": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Other Expenses"'+
                '            },'+
                '            {'+
                '              "value": ""'+
                '            }'+
                '          ]'+
                '        },'+
                '        "Rows": {'+
                '          "Row": ['+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "7.9.5 Bank Charges",'+
                '                    "id": "779"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7950 Bank Charges - Current Account",'+
                '                        "id": "798"'+
                '                      },'+
                '                      {'+
                '                        "value": "-14.34"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7951 Credit Card Charges",'+
                '                        "id": "780"'+
                '                      },'+
                '                      {'+
                '                        "value": "32.45"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 7.9.5 Bank Charges"'+
                '                  },'+
                '                  {'+
                '                    "value": "18.11"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "ColData": ['+
                '                {'+
                '                  "value": "7900 Exchange Rate Variance",'+
                '                  "id": "797"'+
                '                },'+
                '                {'+
                '                  "value": "3.46"'+
                '                }'+
                '              ],'+
                '              "type": "Data"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "8.1 Depreciation / Amortisation",'+
                '                    "id": "786"'+
                '                  },'+
                '                  {'+
                '                    "value": ""'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Rows": {'+
                '                "Row": ['+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "8101 Computer Depreciation",'+
                '                        "id": "787"'+
                '                      },'+
                '                      {'+
                '                        "value": "1050.75"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "8102 Equipment & Furniture Depreciation",'+
                '                        "id": "788"'+
                '                      },'+
                '                      {'+
                '                        "value": "942.61"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total 8.1 Depreciation / Amortisation"'+
                '                  },'+
                '                  {'+
                '                    "value": "1993.36"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "Summary": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Total Other Expenses"'+
                '            },'+
                '            {'+
                '              "value": "2014.93"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "type": "Section",'+
                '        "group": "OtherExpenses"'+
                '      },'+
                '      {'+
                '        "Summary": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Net Other Income"'+
                '            },'+
                '            {'+
                '              "value": "-2014.93"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "type": "Section",'+
                '        "group": "NetOtherIncome"'+
                '      },'+
                '      {'+
                '        "Summary": {'+
                '          "ColData": ['+
                '            {'+
                '              "value": "Net Income"'+
                '            },'+
                '            {'+
                '              "value": "72598.08"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "type": "Section",'+
                '        "group": "NetIncome"'+
                '      }'+
                '    ]'+
                '  }'+
                '}');
        res.setStatusCode(200);
        return res;
    }

}