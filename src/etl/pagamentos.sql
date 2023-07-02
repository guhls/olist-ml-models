SELECT 
    DATE(dtPedido) AS dtPedido,
    COUNT(*) AS qtd_pedido 
FROM pedido
GROUP BY 1;

SELECT * FROM pagamento_pedido;

WITH tb_join AS (
    SELECT 
        t2.*,
        t3.idVendedor
    FROM pedido t1
    LEFT JOIN pagamento_pedido t2
        ON t1.idPedido = t2.idPedido
    LEFT JOIN item_pedido t3
        ON t1.idPedido = t3.idPedido 
    WHERE 
        dtPedido < '2018-01-01' 
        AND dtPedido >= DATE('2018-01-01', '-6 month')
        AND idVendedor IS NOT NULL
    ORDER BY t1.idPedido
),

tb_group AS (
    SELECT 
        idVendedor, 
        descTipoPagamento, 
        COUNT(idPedido) as qtd_venda,
        SUM(vlPagamento) as vl_total
    FROM tb_join
    GROUP BY 1, 2
    ORDER BY 1, 2
)

SELECT
    idVendedor,

    SUM(CASE WHEN descTipoPagamento = 'boleto' THEN qtd_venda ELSE 0 END) qtd_boleto, 
    SUM(CASE WHEN descTipoPagamento = 'credit_card' THEN qtd_venda ELSE 0 END) qtd_credit_card, 
    SUM(CASE WHEN descTipoPagamento = 'debit_card' THEN qtd_venda ELSE 0 END) qtd_debit_card, 
    SUM(CASE WHEN descTipoPagamento = 'voucher' THEN qtd_venda ELSE 0 END) qtd_voucher,

    SUM(CASE WHEN descTipoPagamento = 'boleto' THEN vl_total ELSE 0 END) vl_total_boleto, 
    SUM(CASE WHEN descTipoPagamento = 'credit_card' THEN vl_total ELSE 0 END) vl_total_credit_card, 
    SUM(CASE WHEN descTipoPagamento = 'debit_card' THEN vl_total ELSE 0 END) vl_total_debit_card, 
    SUM(CASE WHEN descTipoPagamento = 'voucher' THEN vl_total ELSE 0 END) vl_total_voucher,

    SUM(CASE WHEN descTipoPagamento = 'boleto' THEN CAST(qtd_venda AS REAL) ELSE 0.0 END) / SUM(qtd_venda) AS pct_boleto, 
    SUM(CASE WHEN descTipoPagamento = 'credit_card' THEN CAST(qtd_venda AS REAL) ELSE 0 END) / SUM(qtd_venda) AS pct_credit_card, 
    SUM(CASE WHEN descTipoPagamento = 'debit_card' THEN CAST(qtd_venda AS REAL) ELSE 0 END) / SUM(qtd_venda) AS pct_debit_card, 
    SUM(CASE WHEN descTipoPagamento = 'voucher' THEN CAST(qtd_venda AS REAL) ELSE 0 END) / SUM(qtd_venda) AS pct_voucher

FROM tb_group 
GROUP BY 1;