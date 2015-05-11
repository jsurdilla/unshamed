class Conversation::ConversationQuery < Mailboxer::Conversation
  def self.unread_count(*user_ids)
    sql = <<-SQL
      SELECT receiver_id, COUNT(*) FROM mailboxer_notifications 
        INNER JOIN mailboxer_receipts ON mailboxer_receipts.notification_id = mailboxer_notifications.id
      WHERE mailboxer_notifications.type = 'Mailboxer::Message'
        AND mailboxer_notifications.type IN ('Mailboxer::Message')
        AND mailboxer_receipts.mailbox_type = 'inbox' 
        AND mailboxer_receipts.trashed = 'f'
        AND mailboxer_receipts.deleted = 'f'
        AND mailboxer_receipts.receiver_id IN (#{user_ids.join(',')})
        AND mailboxer_receipts.receiver_type = 'User'
        AND mailboxer_receipts.is_read = 'f'
      GROUP BY receiver_id
    SQL
    connection.execute(sql).to_a
  end
end