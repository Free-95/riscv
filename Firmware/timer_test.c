#include <stdint.h>

// ============================================================================
// Hardware Definitions
// ============================================================================

// Base Address
#define IO_BASE  0x40000000 

// Timer Register Offsets
#define TIMER_CTRL    (*(volatile uint32_t *)(IO_BASE + 0x0000))
#define TIMER_LOAD    (*(volatile uint32_t *)(IO_BASE + 0x0004))
#define TIMER_VALUE   (*(volatile uint32_t *)(IO_BASE + 0x0008))
#define TIMER_STATUS  (*(volatile uint32_t *)(IO_BASE + 0x000C))

// Control Register Bit Masks
#define CTRL_ENABLE        (1 << 0)
#define CTRL_MODE_PERIODIC (1 << 1) // 0 = One-Shot, 1 = Periodic
#define CTRL_PRESC_EN      (1 << 2)

// Status Register Bit Masks
#define STATUS_TIMEOUT  (1 << 0) // Interrupt Flag (Write 1 to Clear)
#define STATUS_RUNNING  (1 << 1) // Timer is currently counting
#define STATUS_OVERRUN  (1 << 2) // Missed Interrupt Flag (Write 1 to Clear)


// ============================================================================
// Main Test Logic
// ============================================================================

int main() {
    // ------------------------------------------------------------------------
    // TEST 1: One-Shot Mode
    // ------------------------------------------------------------------------
    
    // 1. Load the timer with a countdown value (e.g., 500 ticks)
    TIMER_LOAD = 500;

    // 2. Configure for One-Shot Mode (Bit 1 = 0) and Enable (Bit 0 = 1)
    TIMER_CTRL = CTRL_ENABLE; 

    // 3. Poll the Status Register waiting for the Timeout flag
    while ((TIMER_STATUS & STATUS_TIMEOUT) == 0) {
        // Busy wait until timer hits 0
    }
    printf("Timeout");

    // 4. Verification: In One-Shot mode, the timer should auto-disable.
    // We check if the RUNNING bit (Bit 1) is now 0.
    if (TIMER_STATUS & STATUS_RUNNING) {
        // Test Failed: Timer failed to stop automatically
        return -1; 
    }

    // 5. Clear the Interrupt Flag (Write-1-to-Clear)
    TIMER_STATUS = STATUS_TIMEOUT;


    // ------------------------------------------------------------------------
    // TEST 2: Periodic Mode
    // ------------------------------------------------------------------------

    // 1. Load a value for the periodic cycle
    TIMER_LOAD = 200;

    // 2. Configure for Periodic Mode (Bit 1 = 1) and Enable (Bit 0 = 1)
    TIMER_CTRL = CTRL_ENABLE | CTRL_MODE_PERIODIC;

    // 3. Wait for the FIRST Timeout
    while ((TIMER_STATUS & STATUS_TIMEOUT) == 0);

    // 4. Clear the interrupt flag
    TIMER_STATUS = STATUS_TIMEOUT;

    // 5. Wait for the SECOND Timeout (verifies Auto-Reload worked)
    while ((TIMER_STATUS & STATUS_TIMEOUT) == 0);
    printf("Timeout");

    // 6. Clear the second interrupt
    TIMER_STATUS = STATUS_TIMEOUT;

    // 7. Manually Stop the Timer (since it's periodic, it won't stop itself)
    TIMER_CTRL = 0;


    // ------------------------------------------------------------------------
    // TEST 3: Overrun Detection
    // ------------------------------------------------------------------------
    
    // 1. Load a small value
    TIMER_LOAD = 50;
    
    // 2. Enable in Periodic Mode
    TIMER_CTRL = CTRL_ENABLE | CTRL_MODE_PERIODIC;

    // 3. Wait for Timeout, but DO NOT CLEAR IT.
    while ((TIMER_STATUS & STATUS_TIMEOUT) == 0);

    // 4. Wait long enough for the timer to wrap around and hit 0 again.
    // This should trigger the Overrun hardware logic.
    for (volatile int i = 0; i < 1000; i++); 

    // 5. Check if Overrun Bit (Bit 2) is set
    if ((TIMER_STATUS & STATUS_OVERRUN) == 0) {
        // Test Failed: Overrun logic didn't catch the missed interrupt
        return -2;
    }
    printf("Timeout");

    // 6. Clean up: Stop timer and clear all flags
    TIMER_CTRL = 0;
    TIMER_STATUS = STATUS_TIMEOUT | STATUS_OVERRUN; // Clear both

    return 0; // All Tests Passed
}
