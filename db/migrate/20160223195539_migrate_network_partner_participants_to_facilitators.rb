class MigrateNetworkPartnerParticipantsToFacilitators < ActiveRecord::Migration

  # [assessment_id, user_id]
  ORIGINAL_PARTICIPANTS = {
    production: [[42, 364], [39, 364], [148, 517], [82, 364], [84, 517], [26, 364], [107, 517], [143, 364], [35, 364], [43, 364], [28, 364], [107, 364], [84, 533], [151, 376], [196, 1500], [201, 1694], [46, 364], [48, 364], [53, 364], [33, 381], [35, 383], [35, 374], [56, 364], [70, 382], [71, 382], [72, 364], [59, 402], [110, 517], [111, 517], [112, 517], [113, 376], [114, 376], [35, 382], [48, 391], [58, 396], [58, 364], [153, 376], [116, 376], [115, 376], [66, 364], [68, 364], [122, 364], [141, 923], [173, 383], [152, 376], [145, 465], [145, 533], [146, 364], [165, 1274], [194, 364], [160, 383], [169, 1388], [208, 465], [211, 517], [201, 1637]],
    staging: [[26, 364], [25, 12], [35, 364], [26, 12], [33, 381], [35, 383], [35, 374], [35, 382], [164, 515], [46, 364], [47, 364], [48, 364], [52, 12], [166, 515], [70, 364], [61, 375], [64, 364], [66, 396], [69, 12], [85, 364], [68, 396], [68, 12], [72, 364], [28, 364], [71, 12], [78, 364], [54, 381], [79, 12], [87, 366], [87, 397], [89, 432], [86, 364], [81, 364], [95, 364], [101, 364], [105, 364], [113, 376], [130, 364], [126, 364], [127, 376], [125, 376], [139, 364], [119, 364], [157, 511]]
  }

  def up
    Participant.includes(:user, :assessment).where(users: {role:'network_partner'}).all.each do |participant|
      assessment = participant.assessment
      user = participant.user
      assessment_permission = Assessments::Permission.new(assessment)
      assessment_permission.update_level(user, 'facilitator')
    end
  end

  def down
    original_participants.each do |pair|
      assessment_id, user_id = pair
      assessment = Assessment.where(id: assessment_id).first
      user = User.where(id: user_id).first
      return if !user || !assessment
      assessment_permission = Assessments::Permission.new(assessment)
      assessment_permission.update_level(user, 'participant')
    end
  end

  private
  def original_participants
    env = "#{ENV['ROLLBACK_ENV']}".to_sym
    ORIGINAL_PARTICIPANTS[env] || []
  end
end
