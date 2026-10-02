-- ============================================================
-- ETL MONITORING DASHBOARD
-- Indicadores DAX - versão para portfólio
-- ============================================================


-- ============================================================
-- ATUALIZAÇÃO
-- ============================================================

Atualizado Há =
VAR DataRefresh =
    MAX('Atualização'[DataAtualizacao])

VAR Agora =
    NOW() - TIME(3, 0, 0)

VAR Minutos =
    DATEDIFF(
        DataRefresh,
        Agora,
        MINUTE
    )

RETURN
    "Atualizado há " & Minutos & " min"


Debug Data =
MAX('Atualização'[DataAtualizacao])


-- ============================================================
-- EXECUÇÕES
-- ============================================================

Total Execuções =
COUNTROWS('Execucoes')


Execuções Hoje =
CALCULATE(
    COUNTROWS('Execucoes'),
    'Execucoes'[DataExecucao] >= TODAY()
)


-- ============================================================
-- STATUS
-- ============================================================

Sucessos =
CALCULATE(
    COUNTROWS('Execucoes'),
    'Execucoes'[Status] = "Sucesso"
)


Falhas =
CALCULATE(
    COUNTROWS('Execucoes'),
    'Execucoes'[Status] = "Falha"
)


Falhas Hoje =
CALCULATE(
    COUNTROWS('Execucoes'),
    'Execucoes'[Status] = "Falha",
    'Execucoes'[DataExecucao] >= TODAY()
)


Falha Atual =
IF(
    [Falhas Hoje] > 0,
    1,
    0
)


-- ============================================================
-- TAXAS
-- ============================================================

Taxa Sucesso (%) =
DIVIDE(
    [Sucessos],
    [Total Execuções],
    0
)


Taxa Falha (%) =
DIVIDE(
    [Falhas],
    [Total Execuções],
    0
)


SLA Hoje (%) =
DIVIDE(
    [Execuções Hoje] - [Falhas Hoje],
    [Execuções Hoje],
    0
)


-- ============================================================
-- DURAÇÃO
-- ============================================================

Tempo Médio (s) =
AVERAGE(
    'Execucoes'[DuracaoSegundos]
)


Tempo Médio (min) =
DIVIDE(
    [Tempo Médio (s)],
    60
)


Tempo Mínimo (s) =
MIN(
    'Execucoes'[DuracaoSegundos]
)


Tempo Máximo (min) =
MAX(
    'Execucoes'[Duracao]
)


-- ============================================================
-- ÚLTIMA EXECUÇÃO
-- ============================================================

Última Execução =
MAX(
    'Execucoes'[DataExecucao]
)


Último Status =
VAR UltimaData =
    MAX('Execucoes'[DataExecucao])

RETURN
    CALCULATE(
        SELECTEDVALUE('Execucoes'[Status]),
        'Execucoes'[DataExecucao] = UltimaData
    )


Falhou Última Execução =
VAR UltimaData =
    MAX('Execucoes'[DataExecucao])

RETURN
    CALCULATE(
        COUNTROWS('Execucoes'),
        'Execucoes'[Status] = "Falha",
        'Execucoes'[DataExecucao] = UltimaData
    )


-- ============================================================
-- STATUS POR SCHEDULE
-- ============================================================

Falha Última Execução Schedule =
VAR UltimaDataSchedule =
    CALCULATE(
        MAX('Execucoes'[DataExecucao]),
        ALLEXCEPT(
            'Execucoes',
            'Execucoes'[Schedule]
        )
    )

RETURN
    CALCULATE(
        COUNTROWS('Execucoes'),
        'Execucoes'[Status] = "Falha",
        'Execucoes'[DataExecucao] = UltimaDataSchedule
    )


-- ============================================================
-- STATUS GERAL
-- ============================================================

Status Atual =
VAR TabelaSchedules =
    ADDCOLUMNS(
        VALUES('Execucoes'[Schedule]),
        "UltimaData",
            CALCULATE(
                MAX('Execucoes'[DataExecucao])
            )
    )

VAR TabelaStatus =
    ADDCOLUMNS(
        TabelaSchedules,
        "StatusFinal",
            VAR DataSchedule = [UltimaData]

            RETURN
                CALCULATE(
                    SELECTEDVALUE('Execucoes'[Status]),
                    'Execucoes'[DataExecucao] = DataSchedule
                )
    )

VAR ExisteFalha =
    COUNTROWS(
        FILTER(
            TabelaStatus,
            [StatusFinal] = "Falha"
        )
    ) > 0

RETURN
    IF(
        ExisteFalha,
        "Falha Detectada",
        "Tudo OK"
    )


-- ============================================================
-- INDICADORES VISUAIS
-- ============================================================

Status Alerta =
IF(
    [Status Atual] = "Falha Detectada",
    "🔴 Falha Detectada",
    "🟢 Atualização OK"
)


Status Cor =
SWITCH(
    TRUE(),
    [Falhas Hoje] > 0, "🔴",
    [Execuções Hoje] = 0, "🟡",
    "🟢"
)


Cor Alerta =
IF(
    [Status Atual] = "Falha Detectada",
    "#FF4D4D",
    "#00B050"
)
