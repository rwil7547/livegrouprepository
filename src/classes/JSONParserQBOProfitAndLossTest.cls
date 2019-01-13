/**
 * Created by Ronan Williams on 02/10/2018.
 */

@IsTest
public class JSONParserQBOProfitAndLossTest {

    @IsTest
    static void testParse() {
        String json=		'{'+
                '  "Header": {'+
                '    "Time": "2018-10-02T07:09:19-07:00",'+
                '    "ReportName": "ProfitAndLoss",'+
                '    "DateMacro": "this fiscal year-to-date",'+
                '    "ReportBasis": "Accrual",'+
                '    "StartPeriod": "2018-04-01",'+
                '    "EndPeriod": "2018-10-02",'+
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
                '                    "value": "Revenue",'+
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
                '                        "value": "937518.88"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "4001 Other Income",'+
                '                        "id": "640"'+
                '                      },'+
                '                      {'+
                '                        "value": "9892.18"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total Revenue"'+
                '                  },'+
                '                  {'+
                '                    "value": "947411.06"'+
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
                '              "value": "947411.06"'+
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
                '                    "value": "Exchange Rate Variances",'+
                '                    "id": "778"'+
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
                '                        "value": "7900 Exchange Rate Variance",'+
                '                        "id": "797"'+
                '                      },'+
                '                      {'+
                '                        "value": "88.98"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total Exchange Rate Variances"'+
                '                  },'+
                '                  {'+
                '                    "value": "88.98"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Insurance",'+
                '                    "id": "734"'+
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
                '                        "value": "7200 Other Insurance",'+
                '                        "id": "796"'+
                '                      },'+
                '                      {'+
                '                        "value": "11265.68"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total Insurance"'+
                '                  },'+
                '                  {'+
                '                    "value": "11265.68"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "IT costs",'+
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
                '                        "value": "7350 Directors Meeting Expenses",'+
                '                        "id": "746"'+
                '                      },'+
                '                      {'+
                '                        "value": "13800.66"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7351 Other Travel & Subsistence",'+
                '                        "id": "747"'+
                '                      },'+
                '                      {'+
                '                        "value": "2506.66"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total Travel and subsistence"'+
                '                  },'+
                '                  {'+
                '                    "value": "16307.32"'+
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
                '              "value": "815548.56"'+
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
                '              "value": "-259512.86"'+
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
                '                    "value": "Bank Charges",'+
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
                '                        "value": "1354.09"'+
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
                '                        "value": "513.21"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  },'+
                '                  {'+
                '                    "ColData": ['+
                '                      {'+
                '                        "value": "7952 Bank Charges - Delegate Fees Account",'+
                '                        "id": "781"'+
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
                '                    "value": "Total Bank Charges"'+
                '                  },'+
                '                  {'+
                '                    "value": "1867.30"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Depreciation / Amortisation",'+
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
                '                        "value": "5437.06"'+
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
                '                        "value": "5485.54"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total Depreciation / Amortisation"'+
                '                  },'+
                '                  {'+
                '                    "value": "10922.60"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "type": "Section"'+
                '            },'+
                '            {'+
                '              "Header": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Finance Costs",'+
                '                    "id": "782"'+
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
                '                        "value": "8000 Bank Interest",'+
                '                        "id": "783"'+
                '                      },'+
                '                      {'+
                '                        "value": "240.16"'+
                '                      }'+
                '                    ],'+
                '                    "type": "Data"'+
                '                  }'+
                '                ]'+
                '              },'+
                '              "Summary": {'+
                '                "ColData": ['+
                '                  {'+
                '                    "value": "Total Finance Costs"'+
                '                  },'+
                '                  {'+
                '                    "value": "240.16"'+
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
                '              "value": "13030.06"'+
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
                '              "value": "-13030.06"'+
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
                '              "value": "-272542.92"'+
                '            }'+
                '          ]'+
                '        },'+
                '        "type": "Section",'+
                '        "group": "NetIncome"'+
                '      }'+
                '    ]'+
                '  }'+
                '}';
        JSONParserQBOProfitAndLoss obj = JSONParserQBOProfitAndLoss.parse(json);
        System.assert(obj != null);
    }

}