import("core.base.scheduler")

local inftimeout = 5000

function test_single_process(t)

    local stdout = os.tmpfile()
    local stderr = os.tmpfile()
    local proc = process.openv("xmake", {"lua", "print", "xmake"}, {stdout = stdout, stderr = stderr})
    proc:wait(inftimeout)
    proc:close()
    t:are_equal(io.readfile(stdout):trim(), "xmake")
end

function test_sched_process(t)

    local count = 0
    local _session = function ()
        local stdout = io.open(os.tmpfile(), 'w')
        local stderr = io.open(os.tmpfile(), 'w')
        local proc = process.openv("xmake", {"lua", "print", "xmake"}, {stdout = stdout, stderr = stderr})
        local ok, status = proc:wait(inftimeout)
        proc:close()
        stdout:close()
        stderr:close()
        count = count + 1
    end
    local cotasks = {}
    for i = 1, 3 do
        table.insert(cotasks, scheduler.co_start(_session))
    end
    scheduler.co_waitexit(cotasks)
    t:are_equal(count, 3)
end
