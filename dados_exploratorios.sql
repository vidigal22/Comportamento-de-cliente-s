-- Distribuição por Escolaridade
SELECT Education, COUNT(*) AS Quantidade_Clientes 
FROM marketing
GROUP BY Education
ORDER BY Quantidade_Clientes DESC;

-- Distribuição por Estado Civil
SELECT Marital_Status, COUNT(*) AS Quantidade_Clientes 
FROM marketing
GROUP BY Marital_Status
ORDER BY Quantidade_Clientes DESC;

-- Calcular Idade media com Base no Ano de Nascimento
SELECT AVG(YEAR(CURDATE()) - Year_Birth) AS Idade_Media 
FROM marketing;

-- Distribuição do Total Gasto por Categoria
SELECT 
    'Vinho' AS Categoria, 
    CONCAT('U$ ', FORMAT(SUM(MntWines), 2)) AS Total_Gasto 
FROM marketing
UNION ALL
SELECT 
    'Frutas', 
    CONCAT('U$ ', FORMAT(SUM(MntFruits), 2)) 
FROM marketing
UNION ALL
SELECT 
    'Carne', 
    CONCAT('U$ ', FORMAT(SUM(MntMeatProducts), 2)) 
FROM marketing
UNION ALL
SELECT 
    'Peixes', 
    CONCAT('U$ ', FORMAT(SUM(MntFishProducts), 2)) 
FROM marketing
UNION ALL
SELECT 
    'Doces', 
    CONCAT('U$ ', FORMAT(SUM(MntSweetProducts), 2)) 
FROM marketing
UNION ALL
SELECT 
    'Ouro', 
    CONCAT('U$ ', FORMAT(SUM(MntGoldProds), 2)) 
FROM marketing;

-- Relação entre Número de Crianças/Adolescentes na Casa e Gasto em Doces
SELECT 
    k.kid AS Total_Criancas,
    t.teen AS Total_Adolescentes,
    k.Gasto_Medio AS Gasto_Medio_Crianca,
    t.Gasto_Medio AS Gasto_Medio_Adolescente
FROM
    (SELECT DISTINCT
        Kidhome AS kid,
            CONCAT('U$ ', FORMAT(AVG(MntSweetProducts), 2)) AS Gasto_Medio
    FROM
        marketing
    GROUP BY Kidhome) k
        JOIN
    (SELECT DISTINCT
        Teenhome AS teen,
            CONCAT('U$ ', FORMAT(AVG(MntSweetProducts), 2)) AS Gasto_Medio
    FROM
        marketing
    GROUP BY Teenhome) t ON k.kid = t.teen
ORDER BY Total_Criancas , Total_Adolescentes;

-- Clientes com Maior Gasto em uma Categoria 
WITH RankedData AS (
    SELECT 
        'Vinho' AS Categoria, 
        ID, 
        MntWines AS Gasto,
        ROW_NUMBER() OVER (PARTITION BY 'Vinho' ORDER BY MntWines DESC) AS Ranking
    FROM marketing
    UNION ALL
    SELECT 
        'Frutas', 
        ID, 
        MntFruits,
        ROW_NUMBER() OVER (PARTITION BY 'Frutas' ORDER BY MntFruits DESC)
    FROM marketing
    UNION ALL
    SELECT 
        'Carne', 
        ID, 
        MntMeatProducts,
        ROW_NUMBER() OVER (PARTITION BY 'Carne' ORDER BY MntMeatProducts DESC)
    FROM marketing
    UNION ALL
    SELECT 
        'Peixes', 
        ID, 
        MntFishProducts,
        ROW_NUMBER() OVER (PARTITION BY 'Peixes' ORDER BY MntFishProducts DESC)
    FROM marketing
    UNION ALL
    SELECT 
        'Doces', 
        ID, 
        MntSweetProducts,
        ROW_NUMBER() OVER (PARTITION BY 'Doces' ORDER BY MntSweetProducts DESC)
    FROM marketing
    UNION ALL
    SELECT 
        'Ouro', 
        ID, 
        MntGoldProds,
        ROW_NUMBER() OVER (PARTITION BY 'Ouro' ORDER BY MntGoldProds DESC)
    FROM marketing
)
SELECT 
    ID,
    Categoria,
    CONCAT('U$ ', format(Gasto,2)) as Gasto
FROM RankedData
WHERE Ranking <= 3
ORDER BY Categoria, Gasto DESC;

-- Taxa de Aceitação por Campanha
SELECT 
    'Campanha 1' AS Campanha, 
    ROUND(SUM(AcceptedCmp1) * 100.0 / COUNT(*), 2) AS Taxa_Aceitacao
FROM marketing
UNION ALL
SELECT 
    'Campanha 2', 
    ROUND(SUM(AcceptedCmp2) * 100.0 / COUNT(*), 2)
FROM marketing
UNION ALL
SELECT 
    'Campanha 3', 
    ROUND(SUM(AcceptedCmp3) * 100.0 / COUNT(*), 2)
FROM marketing
UNION ALL
SELECT 
    'Campanha 4', 
    ROUND(SUM(AcceptedCmp4) * 100.0 / COUNT(*), 2)
FROM marketing
UNION ALL
SELECT 
    'Campanha 5', 
    ROUND(SUM(AcceptedCmp5) * 100.0 / COUNT(*), 2)
FROM marketing
UNION ALL
SELECT 
    'Ultima Campanha', 
    ROUND(SUM(Response) * 100.0 / COUNT(*), 2)
FROM marketing;

-- Perfil dos Clientes que Aceitaram a Maioria das Campanhas
SELECT 
    ID,
    (AcceptedCmp1 + AcceptedCmp2 + AcceptedCmp3 + AcceptedCmp4 + AcceptedCmp5) AS Total_Campanhas_Aceitas,
    concat('U$ ', format(Income, 2)) Income,
    Education,
    Marital_Status,
    Kidhome,
    Teenhome
FROM marketing
WHERE (AcceptedCmp1 + AcceptedCmp2 + AcceptedCmp3 + AcceptedCmp4 + AcceptedCmp5) = 4
ORDER BY income 
LIMIT 15;

-- Comparação entre Compras Online e Offline
SELECT 
    'Online' AS Tipo_Compra, 
    SUM(NumWebPurchases + NumCatalogPurchases) AS Total_Compras 
FROM marketing
UNION ALL
SELECT 
    'Offline', 
    SUM(NumStorePurchases)
FROM marketing;

-- Clientes com Mais de 10 Visitas ao Site no Último Mês
SELECT 
    ID, 
    NumWebVisitsMonth AS Visitas_No_Ultimo_Mes,
    CONCAT('U$ ', FORMAT(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds, 2)) AS Gasto_Total
FROM marketing
WHERE NumWebVisitsMonth > 10
ORDER BY Visitas_No_Ultimo_Mes DESC;

-- Clientes que Realizaram Mais Compras Online do que Offline 
SELECT 
    ID,
    NumWebPurchases + NumCatalogPurchases AS Total_Compras_Online,
    NumStorePurchases AS Total_Compras_Offline
FROM marketing
WHERE (NumWebPurchases + NumCatalogPurchases) > NumStorePurchases
ORDER BY Total_Compras_Online DESC;

-- Clientes com Alta Frequência de Visitas mas Poucas Compras
SELECT 
    ID,
    NumWebVisitsMonth AS Visitas_No_Mes,
    NumWebPurchases + NumCatalogPurchases AS Total_Compras_Online,
    CONCAT('U$ ', FORMAT(MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds, 2)) AS Gasto_Total
FROM marketing
WHERE NumWebVisitsMonth > 10 AND (NumWebPurchases + NumCatalogPurchases) <= 2
ORDER BY Visitas_No_Mes DESC;


