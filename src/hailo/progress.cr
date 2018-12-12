require "progress"

module Hailo::Progress
  private def with_progress(size, message, timed = false, print = true) : Nil
    if timed && print
      before = Time.now
    end

    puts message if print
    update_progress = progress_callback(size)
    yield update_progress

    if before && print
      span = Time.now - before
      rate = (size / span.total_milliseconds * 1000).to_i
      secs = sprintf "%.1f", span.to_f
      puts "Processed #{size} in #{secs} seconds; #{rate}/s"
    end
  end

  # this callback avoids calling ProgressBar#inc more than 10k times
  private def progress_callback(size) : Proc
    factor = 1
    total = size
    if size > 10_000 # precision: 99.99%
      factor = (size / 10_000).floor
      total = (size / factor).floor
    end

    progress_bar = ProgressBar.new(total: total, width: 40)
    remaining = size

    ->(processed : Int32) {
      processed.times do
        progress_bar.inc if remaining % factor == 0
        remaining -= 1
      end
    }
  end
end
