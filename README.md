ETL Monitoring Dashboard

Dashboard em Power BI para acompanhar a saúde das rotinas de integração de dados (ETL) agendadas no SQL Server Agent.

A ideia é que em vez de abrir o histórico de jobs do SQL Server e procurar falhas manualmente, o dashboard mostra em uma única tela o que rodou, o que falhou, quanto tempo levou e qual é o status atual de cada schedule.

  O que o dashboard responde

- Está tudo rodando bem agora? Algum schedule falhou na última execução?
- Quantas execuções aconteceram hoje e quantas falharam?
- Qual a taxa de sucesso e de falha no período?
- Quais schedules concentram mais falhas?
- Quanto tempo as execuções levam em média, e qual foi a mais longa?
- Há quanto tempo os dados foram atualizados?

  Visão geral da solução

SQL Server Agent (msdb)  ──►  Query T-SQL  ──►  Modelo Power BI  ──►  Dashboard
 sysjobs / sysjobsteps         sql/               tabelas +           indicadores,
 sysjobhistory                                    medidas DAX         alertas e tabelas
                                                  dax/

1. Fonte: o histórico de execução dos jobs fica nas tabelas de sistema do msdb.
2. Query: sql/query_schedule.sql consolida o histórico em uma linha por execução de etapa.
3. Modelo: duas tabelas, Execucoes (resultado da query) e Atualização (data/hora do último refresh, por exemplo gerada com DateTime.LocalNow() no Power Query).
4. Medidas: dax/indicadores.dax concentra todos os indicadores (taxas, tempos, status por schedule, alertas).

   Principais indicadores

| Taxa de Sucesso / Falha (%) | Proporção de execuções com sucesso e com falha no período |
| Total de Execuções | Volume total analisado |
| Tempo Médio / Máximo | Duração média e da execução mais longa |
| Execuções e Falhas Hoje | Volume do dia e quantas falharam |
| Último Status por Schedule | Status da execução mais recente de cada schedule |
| Status Geral (Atualização OK / Falha Detectada) | Alerta consolidado: acende se qualquer schedule falhou na última execução |
| Atualizado há X min | Frescor dos dados exibidos |
| Taxa de Sucesso por Schedule | Comparativo de confiabilidade entre schedules |

  Tecnologias

SQL Server · SQL Server Agent (msdb) · T-SQL · Power BI · DAX

  Estrutura do repositório

etl-monitoring-dashboard/
├── README.md
├── sql/
│   └── query_schedule.sql     # consulta ao histórico do SQL Server Agent
├── dax/
│   └── indicadores.dax        # medidas do Power BI
└── images/
    └── dashboard.png          # print do dashboard

  Autor

[Denise Jesus Teixeira] · www.linkedin.com/in/denise-teixeira-ab1896146 
