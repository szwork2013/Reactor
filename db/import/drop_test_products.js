shellHelper.use('test');
db.products.remove({category: 'combo'});
db.products.remove({batch:{$exists: false}});
