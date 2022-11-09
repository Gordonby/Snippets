//Find a specific book
Books
| where book_title == 'De Revolutionibus Magnis Data'

//Shelf data
Shelves
| take 5

//Which shelf is a book on
Shelves
| mv-expand rf_ids
| extend rf_ids =tostring(rf_ids)
| join Books on $left.rf_ids == $right.rf_id
| project book_title, shelf
| take 5

//Which books aren't on shelves
Shelves
| mv-expand rf_ids
| extend rf_ids =tostring(rf_ids)
| join kind=rightouter Books on $left.rf_ids == $right.rf_id
| where isnull(shelf)
| take 5
| project book_title, shelf


// Shelf weight vs Book lookup weight
Shelves
| mv-expand rf_ids
| extend rf_ids =tostring(rf_ids)
| join kind=inner Books on $left.rf_ids == $right.rf_id
| summarize rfIdbookWeight=sum(weight_gram) by shelf, total_weight

// Which shelves have weight dicrepancies
Shelves
| mv-expand rf_ids
| extend rf_ids =tostring(rf_ids)
| join kind=inner Books on $left.rf_ids == $right.rf_id
| summarize rfIdbookWeight=sum(weight_gram) by shelf, total_weight
| extend dicrepancy = (total_weight - rfIdbookWeight)
| order by dicrepancy desc 
| take 5
