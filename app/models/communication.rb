class Communication < ApplicationRecord
  belongs_to :order

  KINDS = %w[ready retard information_needed].freeze
  CHANNELS = %w[email sms].freeze
  STATUSES = %w[pending sent failed skipped].freeze

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :content, presence: true
  validates :channel, inclusion: { in: CHANNELS }, allow_blank: true

  def kind_label
    {
      "ready" => "Commande prête",
      "retard" => "Retard",
      "information_needed" => "Demande d’information"
    }[kind] || kind
  end

  def status_label
    {
      "pending" => "Brouillon",
      "sent" => "Envoyé",
      "failed" => "Échec",
      "skipped" => "Ignoré"
    }[status] || status
  end
end
