gcloud  = require 'gcloud'
pathmod = require 'path'
walk    = require 'walkdir'
fs      = require 'fs'
async   = require 'async'

rootpath = pathmod.join __dirname, '..'

config = require '../config'

storage = gcloud.storage {
  projectId: config.projectid
  keyFilename: rootpath + '/gcs_keyfile.json'
}

pathFilter = (path) ->
  fname = pathmod.basename path
  return false if fs.lstatSync(path).isDirectory()
  return false if fname.indexOf('.') is 0
  true


class Uploader

  constructor: ->

    filesdir = rootpath+'/files'
    paths = walk.sync(filesdir)
    paths = paths.filter pathFilter

    async.each paths,
      (path, cb) ->
        console.log 'going to upload', path
        bucket  = storage.bucket(config.bucket)
        image   = bucket.file(pathmod.basename(path))

        fileobject = fs.createReadStream path
        fileobject.pipe(image.createWriteStream())

        fileobject.on 'error', (err) ->
          console.log 'error is', err if err

        fileobject.on 'end', ->
          console.log ' uploading', path
          cb()
      (err) ->
        console.log 'all files done...'






module.exports = Uploader

