namespace :redis_cache do
  task cache_item_supports: :environment do
    Post.includes(:supports).find_in_batches do |posts|
      posts.each do |post|
        assoc_set = RedisCache::AssociatedSet.new("post:#{post.id}", 'supporters')
        assoc_set.add(post.supports.map(&:id)) unless post.supports.empty?
      end
    end

    JournalEntry.includes(:supports).find_in_batches do |journal_entries|
      journal_entries.each do |journal_entry|
        assoc_set = RedisCache::AssociatedSet.new("journal_entry:#{journal_entry.id}", 'supporters')
        assoc_set.add(journal_entry.supports.map(&:id)) unless journal_entry.supports.empty?
      end
    end
  end
end