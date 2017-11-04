// Q22. International dialog
/*
  :param {
    country1: 'Japan',
    country2: 'Ethiopia'
  }
*/
MATCH
  (country1:Country {name: $country1})<-[:isPartOf]-
  (city1:City)<-[:isLocatedIn]-(person1:Person),
  (country2:Country {name: $country2})<-[:isPartOf]-
  (city2:City)<-[:isLocatedIn]-(person2:Person)
WITH person1, person2, city1, 0 AS score
// subscore 1
OPTIONAL MATCH
  (person1)<-[:hasCreator]-(c:Comment)-[:replyOf]->
  (:Message)<-[:hasCreator]-(person2)
WITH
  person1, person2, city1,
  score + (CASE c WHEN NULL THEN 0 ELSE 4 END) AS score
// subscore 2
OPTIONAL MATCH
  (person1)<-[:hasCreator]-(m:Message)<-[:replyOf]-
  (:Comment)<-[:hasCreator]-(person2)
WITH
  person1, person2, city1,
  score + (CASE m WHEN NULL THEN 0 ELSE 1 END) AS score
// subscore 3
OPTIONAL MATCH (person1)-[k:knows]-(person2)
WITH
  person1, person2, city1,
  score + (CASE k WHEN NULL THEN 0 ELSE 15 END) AS score
// subscore 4
OPTIONAL MATCH (person1)-[:likes]->(m:Message)<-[:hasCreator]-(person2)
WITH
  person1, person2, city1,
  score + (CASE m WHEN NULL THEN 0 ELSE 10 END) AS score
// subscore 5
OPTIONAL MATCH (person1)<-[:hasCreator]-(m:Message)<-[:likes]-(person2)
WITH
  person1, person2, city1,
  score + (CASE m WHEN NULL THEN 0 ELSE 1 END) AS score
// preorder
ORDER BY
  city1.name ASC,
  score DESC,
  person1.id ASC,
  person2.id ASC
WITH
  city1,
  // using a list might be faster, but the browser editor does not like it
  collect({score: score, person1: person1, person2: person2})[0] AS top
RETURN
  top.person1.id,
  top.person2.id,
  city1.name,
  top.score
ORDER BY
  top.score DESC,
  top.person1.id ASC,
  top.person2.id ASC