<?php
/**
 * Verbose result printer
 *
 * Add this to the configuration file (phpunit.xml) as attributes to the top level "phpunit" xml node
 * printerClass="PHPUnit_VerboseResultPrinter"
 * printerFile="lib/sd_tests/PHPUnit_VerboseResultPrinter.php"
 *
 *
 * @author Fabrizio Branca
 * @since 2011-11-07
 */
class PHPUnit_VerboseResultPrinter extends PHPUnit_TextUI_ResultPrinter {

	/**
	 * @var int
	 */
	protected $level = -1;

	/**
	 * @var array
	 */
	protected $starttimes = array();

    /**
     * Constructor
     *
     * @param null $out
     * @param bool $verbose
     * @param bool $colors
     * @param bool $debug
     */
    public function __construct($out = NULL, $verbose = FALSE, $colors = FALSE, $debug = FALSE)
    {
        parent::__construct($out, $verbose, $colors, $debug);

        // this class being used as a printerClass doesn't receive any configuration from PHPUnit.
        // that's we need this hack...
        if (isset($_SERVER['argv']) && in_array('--colors', $_SERVER['argv'])) {
            $this->colors = true;
        }
    }

	/**
	 * Get duration
	 *
	 * @return float
	 */
	protected function getDuration() {
		$duration = microtime(true) - $this->starttimes[$this->level];
		return round($duration, $duration < 10 ? 2 : 0);
	}

	/**
	 * An error occurred.
	 *
	 * @param PHPUnit_Framework_Test $test
	 * @param Exception $e
	 * @param float $time
	 * @return void
	 */
	public function addError(PHPUnit_Framework_Test $test, Exception $e, $time) {
		$message = sprintf("%s  ERROR: %s (Duration: %s sec)", str_repeat('  ', $this->level), str_replace("\n", " ", $e->getMessage()), $this->getDuration());

		if ($this->colors) {
			$this->write("\x1b[31;1m$message\x1b[0m" . "\n");
		} else {
			$this->write($message . "\n");
		}

		$this->lastTestFailed = TRUE;
	}

	/**
	 * A failure occurred.
	 *
	 * @param PHPUnit_Framework_Test $test
	 * @param PHPUnit_Framework_AssertionFailedError $e
	 * @param float $time
	 * @return void
	 */
	public function addFailure(PHPUnit_Framework_Test $test, PHPUnit_Framework_AssertionFailedError $e, $time) {
		$message = sprintf("%s  FAILURE: %s (Duration: %s sec)", str_repeat('  ', $this->level), str_replace("\n", " ", $e->getMessage()), $this->getDuration());

		if ($this->colors) {
			$this->write("\x1b[41;37m$message\x1b[0m" . "\n");
		} else {
			$this->write($message . "\n");
		}

		$this->lastTestFailed = TRUE;
	}

	/**
	 * Incomplete test.
	 *
	 * @param PHPUnit_Framework_Test $test
	 * @param Exception $e
	 * @param float $time
	 * @return void
	 */
	public function addIncompleteTest(PHPUnit_Framework_Test $test, Exception $e, $time) {
		$message = sprintf("%s  INCOMPLETE: %s (Duration: %s sec)", str_repeat('  ', $this->level), str_replace("\n", " ", $e->getMessage()), $this->getDuration());

		if ($this->colors) {
			$this->write("\x1b[33;1m$message\x1b[0m" . "\n");
		} else {
			$this->write($message . "\n");
		}

		$this->lastTestFailed = TRUE;
	}

	/**
	 * Skipped test.
	 *
	 * @param PHPUnit_Framework_Test $test
	 * @param Exception $e
	 * @param float $time
	 * @return void
	 */
	public function addSkippedTest(PHPUnit_Framework_Test $test, Exception $e, $time) {
		// $this->startTest($test);
		$message = sprintf("%s  SKIPPED: %s (Duration: %s sec)", str_repeat('  ', $this->level), str_replace("\n", " ", $e->getMessage()), $this->getDuration());

		if ($this->colors) {
			$this->write("\x1b[36;1m$message\x1b[0m"  . "\n");
		} else {
			$this->write($message  . "\n");
		}

		$this->lastTestFailed = TRUE;
		// $this->endTest($test, $time);
	}

	/**
	 * A testsuite started.
	 *
	 * @param PHPUnit_Framework_TestSuite $suite
	 * @return void
	 */
	public function startTestSuite(PHPUnit_Framework_TestSuite $suite) {
		$this->level++;
		$this->starttimes[$this->level] = microtime(true);
		$this->write(sprintf("%s> SUITE: %s\n", str_repeat('  ', $this->level), PHPUnit_Util_Test::describe($suite)));
		return parent::startTestSuite($suite);
	}

	/**
	 * A testsuite ended.
	 *
	 * @param  PHPUnit_Framework_TestSuite $suite
	 * @return void
	 */
	public function endTestSuite(PHPUnit_Framework_TestSuite $suite) {
		$this->write(sprintf("%s< Duration: %s sec\n", str_repeat('  ', $this->level), $this->getDuration()));
		$this->level--;
		return parent::endTestSuite($suite);
	}

	/**
	 * A test started.
	 *
	 * @param PHPUnit_Framework_Test $test
	 * @return void
	 */
	public function startTest(PHPUnit_Framework_Test $test) {
		$this->level++;
		$this->starttimes[$this->level] = microtime(true);
		$this->write(sprintf("%s> TEST: %s\n", str_repeat('  ', $this->level), PHPUnit_Util_Test::describe($test)));
	}

	/**
	 * A test ended.
	 *
	 * @param PHPUnit_Framework_Test $test
	 * @param float $time
	 * @return void
	 */
	public function endTest(PHPUnit_Framework_Test $test, $time) {

        if (method_exists($test, 'getMessages')) {
            foreach ($test->getMessages() as $testMessage) {
                $testMessage = sprintf("%s  [%s]", str_repeat('  ', $this->level), $testMessage);
                $this->write($testMessage . "\n");
            }
        }

		if (!$this->lastTestFailed) {
			$message = sprintf("%s  SUCCESS. (Duration: %s sec)", str_repeat('  ', $this->level), $this->getDuration());

            if ($this->colors) {
                $this->write("\x1b[32;1m$message\x1b[0m" . "\n");
            } else {
                $this->write($message . "\n");
            }
		}
		$this->level--;
		return parent::endTest($test, $time);
	}

	/**
	 * Override parent method to avoid something to be displayed
	 *
	 * @param string $progress
	 * @return void
	 */
	protected function writeProgress($progress) { }

}
