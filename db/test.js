const db = new (require('level').Level)(require('path').resolve(__dirname, './db'), { prefix: 'testt' })

;(async () => {
  await db.put('test', 'test')
  console.log(await db.get('test'))
  await db.del('test')
  console.log(await db.get('test'))
  await db.batch([
    { type: 'put', key: 'test1', value: 'test1' },
    { type: 'put', key: 'test2', value: 'test2' },
    { type: 'del', key: 'test1' }
  ])
  console.log(await db.get('test1'))
  console.log(await db.get('test2'))
})()

module.exports.db = db
