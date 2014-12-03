express = require('express')
config  = require('config')
router  = express.Router()

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
StudentAccount   = require (config.get('paths.models') + '/student_account')
TeacherAccount   = require (config.get('paths.models') + '/teacher_account')
serializers      = require(config.get('paths.serializers'))

module.exports = (app) ->
  app.use('/api/v0/guides', router)

addOrRemoveStudent = (studentCommand, teacherCommand) -> (req, res, next) ->

router
  .get '/', (req, res, next) ->
    TeacherAccount.find(is_guide: true).exec()
      .then (guides) ->
        res.send(guides: guides.map(serializers.teacherAccount))
      .then null, next

  .get '/:id', (req, res, next) ->
    TeacherAccount.findOne(_id: req.params.id, is_guide: true).exec()
      .then (guide) ->
        if guide then res.send(guide: serializers.teacherAccount(guide))
        else controllersUtils.notFound(res)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id/students', (req, res, next) ->
    TeacherAccount.findOne(_id: req.params.id, is_guide: true).exec()
      .then (guide) ->
        return controllersUtils.notFound(res) unless guide

        StudentAccount.find(_id: {$in: guide.students_ids}).exec()
          .then (students) ->
            res.send(student_accounts: students.map(serializers.studentAccount))
      .then null, controllersUtils.mongooseErr(res, next)

  .put '/:id/add_student/:studentId', (req, res, next) ->
    studentId = req.params.studentId
    teacherId = req.params.teacherId

    TeacherAccount.findOne(_id: teacherId, is_guide: true, students_ids: {$ne: studentId}).exec()
      .then (guide) ->
        return controllersUtils.notFound(res) unless guide
        StudentAccount.findByIdAndUpdate(studentId, teacher_id: teacherId).exec()
          .then (student) ->
            return controllersUtils.notFound(res) unless student
            guide.update($addToSet: {students_ids: studentId}).exec()
              .then (updatedGuide) ->
                if updatedGuide
                  res.send
                    student_account: serializers.studentAccount(student)
                    teacher_account: serializers.teacherAccount(updatedGuide)
                else
                  controllersUtils.notFound(res)
              .then null, controllersUtils.mongooseErr(res, next)
          .then null, controllersUtils.mongooseErr(res, next)
      .then null, controllersUtils.mongooseErr(res, next)